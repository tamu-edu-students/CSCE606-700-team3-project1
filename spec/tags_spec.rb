require_relative '../lib/profresh'
require 'json'
require 'date'
require 'tmpdir'

describe 'Add and Remove Tags' do

    module SpecHelpers
        def task_file_path
            ENV.fetch('PROFRESH_DATA_FILE')
        end

        def delete_task_by_id(target_id)
            path = task_file_path
            return unless target_id && File.exist?(path)

            data = JSON.parse(File.read(path))
            if data['tasks']
                data['tasks'].reject! { |task| task['id'] == target_id }
                File.write(path, JSON.pretty_generate(data))
            end
        end
    end

    include SpecHelpers

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