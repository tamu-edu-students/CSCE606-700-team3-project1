require_relative '../lib/profresh'
require 'tmpdir'
require 'stringio'

describe 'Merged task APIs' do
    around do |example|
        Dir.mktmpdir('profresh-merged') do |directory|
            @path = File.join(directory, 'tasks.json')
            previous = ENV['PROFRESH_DATA_FILE']
            ENV['PROFRESH_DATA_FILE'] = @path
            begin
                example.run
            ensure
                ENV['PROFRESH_DATA_FILE'] = previous
            end
        end
    end

    it 'loads old pending tasks and slash dates without rewriting on read' do
        id = add_task('write code', 'high', '9/26/2026')
        data = load_data
        task = data['tasks'].first
        task['status'] = 'pending'
        task['date_due'] = '9/13/2026'
        task['updated'] = (Date.today - 14).iso8601
        task['tags'] = ['CSCE 606']
        File.write(@path, JSON.generate(data))
        original = File.read(@path)

        output = StringIO.new
        expect(ProFresh.new.run(['list', 'incomplete', 'date_due'], output: output)).to eq(0)
        expect(output.string).to include('write code', '2026-09-13', '[stale]')
        expect(File.read(@path)).to eq(original)

        edit_priority(id, 'low')
        task = JSON.parse(File.read(@path))['tasks'].first
        expect(task).to include('id' => id, 'status' => 'incomplete',
                               'date_due' => '2026-09-13', 'tags' => ['CSCE 606'],
                               'updated' => Date.today.iso8601)
        expect(TaskList.new.stale?(task)).to be false
    end

    it 'shares tasks between the teammate APIs and CLI without losing tags' do
        id = add_task('write code', 'high', '9/26/2026')
        add_tag(id, 'CSCE 606')
        add_tag(id, 'CSCE 606')
        expect(load_data['tasks'].first['tags']).to eq(['CSCE 606'])
        edit_date_due(id, '9/13/2026')
        output = StringIO.new
        expect(ProFresh.new.run(['complete', id.to_s], output: output)).to eq(0)
        task = load_data['tasks'].first
        expect(task).to include('status' => 'completed', 'date_due' => '2026-09-13', 'tags' => ['CSCE 606'])
        remove_tag(id, 'CSCE 606')
        add_tag(id, '700')
        clear_tags(id)
        task = load_data['tasks'].first
        expect(task['tags']).to eq([])
        expect(task['finished']).to eq(Date.today.iso8601)
    end

    it 'rejects invalid legacy API edits and invalid dates without changing the file' do
        id = add_task('write code', 'high', '9/26/2026')
        original = File.read(@path)
        expect { edit_priority(id, 'urgent') }.to raise_error(ArgumentError)
        expect { edit_date_due(id, '14/9/2026') }.to raise_error(ArgumentError)
        expect { add_task('invalid', 'high', '14/9/2026') }.to raise_error(ArgumentError)
        expect(File.read(@path)).to eq(original)
    end

    it 'does not overwrite damaged JSON through the teammate APIs' do
        File.write(@path, '{broken')
        expect { add_task('write code', 'high', '9/26/2026') }.to raise_error(Storage::Error)
        expect { save_data('tasks' => []) }.to raise_error(Storage::Error)
        expect { clear_tags(1) }.to raise_error(Storage::Error)
        expect(File.read(@path)).to eq('{broken')
    end
end
