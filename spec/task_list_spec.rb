require_relative '../lib/task_list'

# Stories 5, 7, and 8 use the same fields as the add tests.
describe TaskList do
    def task(id, priority, date_due, status = 'incomplete')
        {
            'id' => id, 'title' => "task #{id}", 'priority' => priority,
            'date_due' => date_due, 'tags' => [], 'status' => status,
            'created' => '2026-09-01', 'updated' => '2026-09-01',
            'finished' => status == 'completed' ? '2026-09-02' : ''
        }
    end

    let(:tasks) do
        [task(1, 'low', '2026-10-01'),
         task(2, 'high', '2026-09-26'),
         task(3, 'medium', '2026-09-14', 'completed')]
    end
    let(:task_list) { TaskList.new(tasks) }

    describe '#list' do
        it 'shows all tasks by default' do
            expect(task_list.list.map { |task| task['id'] }).to eq([1, 2, 3])
        end

        it 'filters incomplete tasks and sorts by due date' do
            result = task_list.list(status: 'incomplete', sort_by: 'date_due')
            expect(result.map { |task| task['id'] }).to eq([2, 1])
        end

        it 'sorts priorities high, medium, then low' do
            result = task_list.list(sort_by: 'priority')
            expect(result.map { |task| task['id'] }).to eq([2, 3, 1])
            expect(tasks.map { |task| task['id'] }).to eq([1, 2, 3])
        end

        it 'shows only completed tasks when requested' do
            result = task_list.list(status: 'completed')
            expect(result.map { |task| task['id'] }).to eq([3])
        end

        it 'returns an empty list when no tasks match' do
            expect(TaskList.new.list(sort_by: 'date_due')).to eq([])
            expect(TaskList.new([tasks.first]).list(status: 'completed')).to eq([])
        end

        it 'rejects unknown filters and sort orders' do
            expect { task_list.list(status: 'unknown') }.to raise_error(ArgumentError, 'invalid status')
            expect { task_list.list(sort_by: 'title') }.to raise_error(ArgumentError, 'invalid sort order')
        end
    end

    describe '#complete' do
        it 'records completion and removes the task from incomplete results' do
            allow(Date).to receive(:today).and_return(Date.new(2026, 9, 14))
            task_list.complete(2)
            expect(tasks[1]).to include('status' => 'completed',
                                       'finished' => '2026-09-14', 'updated' => '2026-09-14')
            expect(task_list.list(status: 'incomplete').map { |task| task['id'] }).to eq([1])
            expect(tasks.first['status']).to eq('incomplete')
        end

        it 'preserves the finish time when a task is already completed' do
            before = tasks.last.dup
            task_list.complete(3)
            expect(tasks.last).to eq(before)
        end

        it 'does not change data when the ID is missing' do
            before = Marshal.dump(tasks)
            expect { task_list.complete(99) }.to raise_error(ArgumentError, 'task not found')
            expect(Marshal.dump(tasks)).to eq(before)
        end
    end

    describe '#delete' do
        it 'removes only the selected task and preserves the other data' do
            remaining = [tasks[0].dup, tasks[2].dup]
            expect(task_list.delete(2)['id']).to eq(2)
            expect(tasks).to eq(remaining)
            expect(task_list.list).to eq(remaining)
        end

        it 'does not change data when the ID is missing' do
            before = Marshal.dump(tasks)
            expect { task_list.delete(99) }.to raise_error(ArgumentError, 'task not found')
            expect(Marshal.dump(tasks)).to eq(before)
        end

        it 'can delete the last task' do
            single = TaskList.new([tasks.first])
            single.delete(1)
            expect(single.list).to eq([])
        end
    end
end
