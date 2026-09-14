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

    def add(title, priority, date_due)
        raise ArgumentError, 'title cannot be empty' if title.strip.empty?
        raise ArgumentError, 'invalid priority' unless ['low', 'medium', 'high'].include?(priority)
        due = parse_due_date(date_due)
        id = (@tasks.map { |task| task['id'] }.max || 0) + 1
        today = Date.today.iso8601
        @tasks << { 'id' => id, 'title' => title, 'priority' => priority,
                    'date_due' => due, 'tags' => [], 'status' => 'incomplete',
                    'created' => today, 'updated' => today, 'finished' => '' }
        id
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

    def stale?(task, today: Date.today)
        task['status'] == 'incomplete' && today - Date.iso8601(task['updated']) >= 14
    end

    def edit(id, title: nil, priority: nil, date_due: nil)
        task = find_task(id)
        changes = {}
        unless title.nil?
            raise ArgumentError, 'title cannot be empty' if title.strip.empty?
            changes['title'] = title
        end
        unless priority.nil?
            raise ArgumentError, 'invalid priority' unless ['low', 'medium', 'high'].include?(priority)
            changes['priority'] = priority
        end
        unless date_due.nil?
            changes['date_due'] = parse_due_date(date_due)
        end
        unless changes.empty?
            task.merge!(changes)
            task['updated'] = Date.today.iso8601
        end
        task
    end

    private

    def parse_due_date(value)
        if value.match?(/\A\d{4}-\d{2}-\d{2}\z/)
            Date.iso8601(value).iso8601
        elsif value.match?(/\A\d{1,2}\/\d{1,2}\/\d{4}\z/)
            Date.strptime(value, '%m/%d/%Y').iso8601
        else
            raise ArgumentError
        end
    rescue ArgumentError
        raise ArgumentError, 'invalid date; use M/D/YYYY or YYYY-MM-DD'
    end

    def find_task(id)
        task = @tasks.find { |entry| entry['id'] == id }
        raise ArgumentError, 'task not found' unless task

        task
    end
end
