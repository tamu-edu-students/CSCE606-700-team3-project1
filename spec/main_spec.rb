require_relative '../lib/profresh'
require 'json'
require 'date'

describe 'adding new task' do

    describe '#add' do

        it 'should be defined' do
            title = "write code"
            priority = "high"
            date_due = "9/26/2026"
            tags = [""]
            expect {add(title, priority, date_due)}.not_to raise_error
        end

        let(:file_path) {File.join(__dir__, '..', 'data', 'task_list.json')}
        let(:parsed_json) do
            file_content = File.read(file_path)
            JSON.parse(file_content)
        end

        it 'json file exists and has tasks array' do
            expect(File.exist?(file_path)).to be true
            expect {parsed_json}.not_to raise_error
            expect(parsed_json).to have_key('tasks')
            expect(parsed_json['tasks']).to be_an(Array)
            expect(parsed_json['tasks']).not_to be_empty
        end

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

    end

    # describe '#add_tag'

        # it 'should be defined'
            # expect not to raise error

        # it 'has tag for correct task'
            # expect to be true
            # expect to eq 'CSCE 606'

    # describe '#edit'

        # it 'should be defined'
            # expect not to raise error

        # it 'properly saves changes'
            # expect priority to eq 'high'

end