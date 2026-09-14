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

        tasks = []
        for task in @tasks
            if status == nil || task['status'] == status
                tasks << task
            end
        end

        if sort_by != nil
            priorities = { 'high' => 0, 'medium' => 1, 'low' => 2 }
            for i in 0...tasks.length
                for j in 0...(tasks.length - 1 - i)
                    if sort_by == 'date_due'
                        left = Date.iso8601(tasks[j]['date_due'])
                        right = Date.iso8601(tasks[j + 1]['date_due'])
                    else
                        left = priorities.fetch(tasks[j]['priority'])
                        right = priorities.fetch(tasks[j + 1]['priority'])
                    end
                    if left > right
                        temp = tasks[j]
                        tasks[j] = tasks[j + 1]
                        tasks[j + 1] = temp
                    end
                end
            end
        end

        tasks
    end

    def add(title, priority, date_due)
        raise ArgumentError, 'title cannot be empty' if title.strip.empty?
        raise ArgumentError, 'invalid priority' unless ['low', 'medium', 'high'].include?(priority)
        due = parse_due_date(date_due)
        id = 1
        for task in @tasks
            if task['id'] >= id
                id = task['id'] + 1
            end
        end
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
        if task['status'] != 'incomplete'
            return false
        end
        days = today - Date.iso8601(task['updated'])
        if days >= 14
            return true
        end
        false
    end

    def edit(id, title: nil, priority: nil, date_due: nil)
        task = find_task(id)
        changed = false
        unless title.nil?
            raise ArgumentError, 'title cannot be empty' if title.strip.empty?
            changed = true
        end
        unless priority.nil?
            raise ArgumentError, 'invalid priority' unless ['low', 'medium', 'high'].include?(priority)
            changed = true
        end
        unless date_due.nil?
            date_due = parse_due_date(date_due)
            changed = true
        end
        if changed
            if title != nil
                task['title'] = title
            end
            if priority != nil
                task['priority'] = priority
            end
            if date_due != nil
                task['date_due'] = date_due
            end
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
        for task in @tasks
            if task['id'] == id
                return task
            end
        end
        raise ArgumentError, 'task not found'
    end
end
