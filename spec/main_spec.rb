require_relative '../lib/profresh'
require 'json'
require 'date'
require 'tmpdir'

describe 'Add and edit tasks and tags' do
    around do |example|
        Dir.mktmpdir('profresh-main') do |directory|
            previous = ENV['PROFRESH_DATA_FILE']
            ENV['PROFRESH_DATA_FILE'] = File.join(directory, 'tasks.json')
            begin
                example.run
            ensure
                ENV['PROFRESH_DATA_FILE'] = previous
            end
        end
    end

    # Retrieve json file and contents to be used in testing
    def task_file_path
        ENV.fetch('PROFRESH_DATA_FILE')
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

        let(:file_path) { task_file_path }
        let(:parsed_json) do
            file_content = File.read(file_path)
            JSON.parse(file_content)
        end

        before(:each) do
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
        it 'json file exists and has tasks array and creates if it not existing' do
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
        after(:each) do
            delete_task_by_id(@id)
        end

    end


    describe '#add_tag and #remove_tag' do

        let(:file_path) { task_file_path }
        let(:parsed_json) do
            file_content = File.read(file_path)
            JSON.parse(file_content)
        end

        before(:each) do
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

        it 'deletes the tag so it is no longer associated with the task' do
            remove_tag(@id, "CSCE 606")

            updated_task = JSON.parse(File.read(file_path))['tasks'].find {|task| task['id'] == @id}
            expect(updated_task['tags']).not_to include('CSCE 606')
        end

        after(:each) do
            delete_task_by_id(@id)
        end

    end


    describe '#edit_task' do


        let(:file_path) {ENV.fetch('PROFRESH_DATA_FILE')}
        let(:parsed_json) do
            file_content = File.read(file_path)
            JSON.parse(file_content)
        end

        before(:each) do
            title = "write stories"
            priority = "medium"
            date_due = "9/26/2026"
            @id = add_task(title, priority, date_due)
        end

        it 'changes the priority of the "write stories" task to high' do
            expect {edit_priority(@id, 'high')}.not_to raise_error
            task = parsed_json['tasks'].find {|task| task['id'] == @id}
            expect(task).not_to be_nil
            expect(task['priority']).to eq('high')
        end

        it 'changes the due date to 9/13/2026' do
            expect {edit_date_due(@id, '9/13/2026')}.not_to raise_error
            task = parsed_json['tasks'].find {|task| task['id'] == @id}
            expect(task).not_to be_nil
            expect(task['date_due']).to eq('2026-09-13')
        end

        after(:each) do
            delete_task_by_id(@id)
        end

    end

    describe '#clear_tags' do

        let(:file_path) {ENV.fetch('PROFRESH_DATA_FILE')}
        let(:parsed_json) do
            file_content = File.read(file_path)
            JSON.parse(file_content)
        end

        before(:each) do
            title = "write code"
            priority = "high"
            date_due = "9/26/2026"
            @id = add_task(title, priority, date_due)
            add_tag(@id, "CSCE 606")
            add_tag(@id, "700")
        end

        it 'removes all tags from the task' do
            expect {clear_tags(@id)}.not_to raise_error
            task = parsed_json['tasks'].find { |task| task['id'] == @id }
            expect(task).not_to be_nil
            expect(task['tags']).to be_an(Array)
            expect(task['tags']).to be_empty
        end

        it 'handles tasks with no tags with no errors' do
            expect {clear_tags(@id)}.not_to raise_error
            task = parsed_json['tasks'].find {|task| task['id'] == @id}
            expect(task['tags']).to eq([])
        end

        after(:each) do
            delete_task_by_id(@id)
        end

    end

end

