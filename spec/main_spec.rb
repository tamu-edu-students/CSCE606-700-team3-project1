require_relative '../lib/profresh'
require 'json'
require 'date'

describe 'Add and edit tasks and tags' do

    # Retrieve json file and contents to be used in testing
    def task_file_path
        File.join(__dir__, '..', 'data', 'task_list.json')
    end

    def delete_task_by_id(target_id)
        path = task_file_path
        return unless target_id && File.exist?(path)

        data = JSON.parse(File.read(path))
        if data['tasks']
            data['tasks'].reject! {|task| task['id'] == target_id}
            File.write(path, JSON.pretty_generate(data))
        end
    end

    describe '#add_task' do

        # Unit Tests for Stories 1, 2, 3, & 4

        let(:file_path) { task_file_path }
        let(:parsed_json) do
            file_content = File.read(file_path)
            JSON.parse(file_content)
        end

        before(:all) do
            title = "write code"
            priority = "high"
            date_due = "9/26/2026"
            @id = add_task(title, priority, date_due)
        end

        # Test add method is defined
        it 'should be defined' do
            expect(@id).not_to be_nil
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
            delete_task_by_id(@id)
        end

    end


    describe '#add_tag' do

        let(:file_path) { task_file_path }
        let(:parsed_json) do
            file_content = File.read(file_path)
            JSON.parse(file_content)
        end

        before(:all) do
            title = "write code b"
            priority = "high"
            date_due = "9/26/2026"
            @id = add_task(title, priority, date_due)
        end

        it 'adds tag to task' do
            expect {add_tag(@id, "CSCE 606")}.not_to raise_error

            task = parsed_json['tasks'].find {|task| task['id'] == @id}
            expect(task).not_to be_nil
            expect(task['tags']).to include('CSCE 606')
        end

        after(:all) do
            delete_task_by_id(@id)
        end

    end


    describe '#edit_priority' do


        let(:file_path) {File.join(__dir__, '..', 'data', 'task_list.json')}
        let(:parsed_json) do
            file_content = File.read(file_path)
            JSON.parse(file_content)
        end

        before(:all) do
            title = "write stories"
            priority = "medium"
            date_due = "9/26/2026"
            @id = add_task(title, priority, date_due)
        end

        it 'changes the priority of the "write stories" task to high' do
            expect {edit_priority(@id, "high") }.not_to raise_error
            task = parsed_json['tasks'].find {|task| task['id'] == @id}
            expect(task).not_to be_nil
            expect(task['priority']).to eq('high')
        end

        after(:all) do
            delete_task_by_id(@id)
        end

    end

end

