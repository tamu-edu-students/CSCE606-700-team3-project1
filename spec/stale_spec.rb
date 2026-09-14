require_relative '../lib/profresh'
require 'stringio'

describe 'Story 6 stale tasks' do
    let(:task) do
        { 'id' => 1, 'title' => 'write code', 'priority' => 'low',
          'date_due' => '2026-09-26', 'status' => 'incomplete', 'updated' => '2026-08-31' }
    end
    let(:list) { TaskList.new([task]) }
    before { allow(Date).to receive(:today).and_return(Date.new(2026, 9, 14)) }

    it 'marks incomplete tasks at exactly 14 days and older' do
        expect(list.stale?(task)).to be true
        task['updated'] = '2026-08-01'
        expect(list.stale?(task)).to be true
    end

    it 'does not mark recent, future, or completed tasks' do
        ['2026-09-01', '2026-09-15'].each do |date|
            task['updated'] = date
            expect(list.stale?(task)).to be false
        end
        task.merge!('updated' => '2026-08-01', 'status' => 'completed')
        expect(list.stale?(task)).to be false
    end

    it 'displays the stale mark and removes it after a CLI edit' do
        app = ProFresh.new(list)
        output = StringIO.new
        expect(app.run(['list'], output: output)).to eq(0)
        expect(output.string).to include('write code', '[stale]')
        expect(app.run(['edit', '1', 'priority', 'high'], output: output)).to eq(0)
        output = StringIO.new
        app.run(['list'], output: output)
        expect(output.string).to include('high')
        expect(output.string).not_to include('[stale]')
        expect(task['updated']).to eq('2026-09-14')
    end

    it 'validates all changes before refreshing or changing a task' do
        original = task.dup
        expect { list.edit(1, title: 'changed', date_due: '2025/13/45') }.to raise_error(ArgumentError, /invalid date/)
        expect { list.edit(1, priority: 'urgent') }.to raise_error(ArgumentError)
        expect { list.edit(1, title: ' ') }.to raise_error(ArgumentError)
        expect { list.edit(99, title: 'changed') }.to raise_error(ArgumentError, 'task not found')
        expect(task).to eq(original)
        list.edit(1)
        expect(task).to eq(original)
    end

    it 'accepts valid due dates and titles and refreshes the task' do
        list.edit(1, title: 'write tests', date_due: '9/27/2026')
        expect(task).to include('title' => 'write tests', 'date_due' => '2026-09-27', 'updated' => '2026-09-14')
        expect(list.stale?(task)).to be false
    end
end
