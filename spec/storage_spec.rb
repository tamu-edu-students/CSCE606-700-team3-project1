require_relative '../lib/profresh'
require 'tmpdir'
require 'open3'
require 'rbconfig'
require 'stringio'

describe 'Story 9 persistence' do
    around do |example|
        Dir.mktmpdir('profresh') do |directory|
            @path = File.join(directory, 'nested', 'tasks.json')
            example.run
        end
    end

    def cli(*arguments)
        Open3.capture3({ 'PROFRESH_DATA_FILE' => @path }, RbConfig.ruby,
                      File.expand_path('../lib/profresh.rb', __dir__), *arguments)
    end

    def saved
        JSON.parse(File.read(@path))['tasks']
    end

    it 'starts empty when the file is missing' do
        output, error, status = cli('list')
        expect(status.success?).to be true
        expect(output).to include('No tasks.')
        expect(error).to eq('')
        expect(File.exist?(@path)).to be false
    end

    it 'persists add, edit, completion, and deletion across separate processes' do
        expect(cli('add', 'write code', 'high', '9/26/2026').last.success?).to be true
        expect(cli('add', 'write tests', 'low', '2026-09-27').last.success?).to be true
        original = saved
        expect(Storage.new(@path).load).to eq(original)
        expect(cli('list').first).to include('write code', 'write tests')
        expect(cli('edit', '1', 'title', 'review code').last.success?).to be true
        expect(saved.first['title']).to eq('review code')
        expect(cli('complete', '1').last.success?).to be true
        completed = saved.first
        expect(completed).to include('status' => 'completed', 'finished' => Date.today.iso8601)
        expect(cli('complete', '1').last.success?).to be true
        expect(saved.first).to eq(completed)
        expect(cli('list', 'incomplete').first).not_to include('review code')
        expect(cli('delete', '1').last.success?).to be true
        expect(saved).to eq([original.last])
        expect(cli('add', 'third task', 'medium', '9/28/2026').last.success?).to be true
        expect(saved.map { |task| task['id'] }).to eq([2, 3])
    end

    it 'preserves tags, all dates, and extra task information on round trip' do
        cli('add', 'write code', 'high', '9/26/2026')
        tasks = saved
        tasks.first.merge!('tags' => ['CSCE 606'], 'notes' => 'keep this')
        Storage.new(@path).save(tasks)
        expect(Storage.new(@path).load).to eq(tasks)
    end

    it 'displays and clears a persisted stale mark after editing' do
        cli('add', 'write code', 'high', '9/26/2026')
        tasks = saved
        tasks.first['updated'] = (Date.today - 14).iso8601
        Storage.new(@path).save(tasks)
        expect(cli('list').first).to include('[stale]')
        expect(cli('edit', '1', 'priority', 'low').last.success?).to be true
        expect(cli('list').first).not_to include('[stale]')
        expect(saved.first['updated']).to eq(Date.today.iso8601)
    end

    it 'rejects invalid commands without modifying saved bytes' do
        cli('add', 'write code', 'high', '9/26/2026')
        original = File.read(@path)
        [['add', 'bad', 'high', '14/9/2026'], ['add', 'bad', 'urgent', '9/26/2026'],
         ['edit', '1', 'date_due', '2026-02-30'], ['complete', '99'],
         ['delete', '99'], ['delete', 'wrong'], ['edit', '1'], ['list', 'wrong']].each do |args|
            output, _, status = cli(*args)
            expect(status.success?).to be false
            expect(output).to include('Error:')
            expect(File.read(@path)).to eq(original)
        end
    end

    it 'reports invalid JSON without overwriting it' do
        FileUtils.mkdir_p(File.dirname(@path))
        File.write(@path, '{broken')
        output, _, status = cli('add', 'write code', 'high', '9/26/2026')
        expect(status.success?).to be false
        expect(output).to include('invalid JSON')
        expect { Storage.new(@path).save([]) }.to raise_error(Storage::Error, /invalid JSON/)
        expect(File.read(@path)).to eq('{broken')
    end

    it 'rejects malformed task data and duplicate IDs without changing it' do
        cli('add', 'write code', 'high', '9/26/2026')
        task = saved.first
        [[], { 'tasks' => [task, task] }, { 'tasks' => [{}] },
         { 'tasks' => [task.merge('updated' => '2026-02-30')] }].each do |data|
            File.write(@path, JSON.generate(data))
            original = File.read(@path)
            expect(cli('list').last.success?).to be false
            expect(File.read(@path)).to eq(original)
        end
    end

    it 'keeps the original file if replacing it fails and reports the failure' do
        cli('add', 'write code', 'high', '9/26/2026')
        original = File.read(@path)
        allow(File).to receive(:rename).and_raise(Errno::EACCES)
        output = StringIO.new
        expect(ProFresh.new(path: @path).run(['delete', '1'], output: output)).to eq(1)
        expect(output.string).to include('cannot save task file')
        expect(output.string).not_to include('Task deleted.')
        expect(File.read(@path)).to eq(original)
        expect(Dir.children(File.dirname(@path))).to eq(['tasks.json'])
    end
end
