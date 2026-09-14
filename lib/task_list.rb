require 'date'

class TaskList
    def initialize(tasks = [])
        @tasks = tasks
    end

    def list(status: nil, sort_by: nil)
        unless [nil, 'incomplete', 'completed'].include?(status)
            raise ArgumentError, 'invalid status'
        end
        unless [nil, 'date_due', 'priority'].include?(sort_by)
            raise ArgumentError, 'invalid sort order'
        end

        tasks = @tasks.dup
        tasks = tasks.select { |task| task['status'] == status } if status

        case sort_by
        when 'date_due'
            tasks = tasks.sort_by { |task| Date.iso8601(task['date_due']) }
        when 'priority'
            priorities = { 'high' => 0, 'medium' => 1, 'low' => 2 }
            tasks = tasks.sort_by { |task| priorities.fetch(task['priority']) }
        end

        tasks
    end

    def complete(id)
        task = find_task(id)
        unless task['status'] == 'completed'
            task['status'] = 'completed'
            task['finished'] = Date.today.iso8601
            task['updated'] = task['finished']
        end
        task
    end

    def delete(id)
        task = find_task(id)
        @tasks.delete_at(@tasks.index(task))
    end

    private

    def find_task(id)
        task = @tasks.find { |entry| entry['id'] == id }
        raise ArgumentError, 'task not found' unless task

        task
    end
end
