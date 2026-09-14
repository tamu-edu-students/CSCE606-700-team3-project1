require_relative '../lib/profresh'
require 'json'
require 'date'

describe 'Adding new task' do

    describe '#add' do

        # Unit Tests for Stories 1 & 3


        id = nil # so we can keep what the expect-add returns and be sure to delete it at end of testing


        # Test add method is defined
        it 'should be defined' do
            title = "write code"
            priority = "high"
            date_due = "9/26/2026"
            expect {
                id = add(title, priority, date_due)
            }.not_to raise_error
        end


        # Retrieve json file and contents to be used in testing
        let(:file_path) {File.join(__dir__, '..', 'data', 'task_list.json')}
        let(:parsed_json) do
            file_content = File.read(file_path)
            JSON.parse(file_content)
        end


        # Make sure json file exists and has an array
        it 'json file exists and has tasks array' do
            expect(File.exist?(file_path)).to be true
            expect {parsed_json}.not_to raise_error
            expect(parsed_json).to have_key('tasks')
            expect(parsed_json['tasks']).to be_an(Array)
            expect(parsed_json['tasks']).not_to be_empty
        end


        # Make sure all elements are present
        it 'stores correct data type in json file' do
            parsed_json['tasks'].each do |task|
                expect(task).to include('id' => be_a(Integer))
                expect(task).to include('title' => be_a(String))
                expect(task).to include('priority' => be_a(String))
                expect(task).to include('date_due' => be_a(String))
                expect(task).to include('tags' => be_an(Array))
                expect(task).to include('status' => be_a(String))
                expect(task).to include('created' => be_a(String))
                expect(task).to include('updated' => be_a(String))
                expect(task).to include('finished' => be_a(String))
            end
        end

        # Easier to sort in iso8601 format - check to ensure it is in correct format
        it 'date stored in proper format ISO8601' do
            parsed_json['tasks'].each do |task|
                expect {Date.iso8601(task['date_due'])}.not_to raise_error
                expect {Date.iso8601(task['created'])}.not_to raise_error
                expect {Date.iso8601(task['updated'])}.not_to raise_error
                unless task['finished'].empty?
                    expect {Date.iso8601(task['finished'])}.not_to raise_error
                end
            end
        end

        # Cleanup - Remove task created for testing from json file
        after(:all) do
            if id && File.exist?(file_path)
                udpated_tasks = parsed_json.reject {|task| task['id'] == id }
                File.write(file_path, JSON.pretty_generate(updated_tasks))
            end
        end

    end

end


describe 'Adding tag to task' do

    title = "write code"
    priority = "high"
    date_due = "9/26/2026"
    id = add(title, priority, date_due)

    let(:file_path) {File.join(__dir__, '..', 'data', 'task_list.json')}
    let(:parsed_json) do
        file_content = File.read(file_path)
        JSON.parse(file_content)
    end

    describe '#add_tag' do

        it 'adds tag to task' do
            expect {add_tag(id, "CSCE 606")}.not_to raise_error

            task = file_content.find {|task| task['id'] == id}
            expect(task).not_to be_nil
            expect(task['tags']).to include('CSCE 606')
        end
    end

    after(:all) do
        if id && File.exist?(file_path)
            udpated_tasks = parsed_json.reject {|task| task['id'] == id }
            File.write(file_path, JSON.pretty_generate(updated_tasks))
        end
    end

end



describe 'editing tasks' do

    title = "write stories"
    priority = "medium"
    date_due = "9/26/2026"
    id = add(title, priority, date_due)

    let(:file_path) {File.join(__dir__, '..', 'data', 'task_list.json')}
    let(:parsed_json) do
        file_content = File.read(file_path)
        JSON.parse(file_content)
    end

    describe '#edit_priority' do
        it 'changes the priority of the "write stories" task to high' do
            expect {edit_priority(id, "high") }.not_to raise_error
            task = file_content.find {|task| tasks['id'] == id}
            expect(task).not_to be_nil
            expect(task['priority']).to eq('high')
        end
    end

    after(:all) do
        if id && File.exist?(file_path)
            udpated_tasks = parsed_json.reject {|task| task['id'] == id }
            File.write(file_path, JSON.pretty_generate(updated_tasks))
        end
    end

end

