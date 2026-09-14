require 'json'
require 'date'

DATA_PATH = File.join(__dir__, '..', 'data', 'task_list.json')

def load_data
    path = ENV.fetch('PROFRESH_DATA_FILE', DATA_PATH)
    {'tasks' => Storage.new(path).load}
end

def save_data(data)
    path = ENV.fetch('PROFRESH_DATA_FILE', DATA_PATH)
    Storage.new(path).save(data['tasks'])
end

def parse_to_iso8601(date_str)
    if date_str.match?(/\A\d{4}-\d{2}-\d{2}\z/)
        Date.iso8601(date_str).iso8601
    elsif date_str.match?(/\A\d{1,2}\/\d{1,2}\/\d{4}\z/)
        Date.strptime(date_str, '%m/%d/%Y').iso8601
    else
        raise ArgumentError, 'invalid date; use M/D/YYYY or YYYY-MM-DD'
    end
end

def add_task(title, priority, date_due)
    add(title, priority, date_due)
end

def add_tag(id, tag)

    data = load_data
    task = data['tasks'].find {|task| task['id'] == id}

    if task
        task['tags'] << tag unless task['tags'].include?(tag)
        task['updated'] = Date.today.iso8601
        save_data(data)
    end

end

def remove_tag(id, tag)

    data = load_data
    task = data['tasks'].find {|task| task['id'] == id}

    if task
        task['tags'].delete(tag)
        task['updated'] = Date.today.iso8601
        save_data(data)
    end

end

def edit_priority(id, priority)

    data = load_data
    task = data['tasks'].find {|task| task['id'] == id}

    if task
        TaskList.new(data['tasks']).edit(id, priority: priority)
        save_data(data)
    end

end

def edit_date_due(id, date)

    data = load_data
    task = data['tasks'].find {|task| task['id'] == id}

    if task
        TaskList.new(data['tasks']).edit(id, date_due: date)
        save_data(data)
    end

end

def clear_tags(id)

    data = load_data
    task = data['tasks'].find {|task| task['id'] == id}

    if task
        task['tags'] = []
        task['updated'] = Date.today.iso8601
        save_data(data)
    end

end
require_relative 'task_list'
require_relative 'storage'

class ProFresh
    def initialize(task_list = nil, path: ENV.fetch('PROFRESH_DATA_FILE', File.expand_path('../data/task_list.json', __dir__)))
        @storage = Storage.new(path) unless task_list
        @task_list = task_list
    end

    def run(arguments, output: $stdout)
        @task_list = TaskList.new(@storage.load) if @storage
        command = arguments[0]
        args = arguments.drop(1)
        case command
        when 'list'
            raise ArgumentError, 'usage: list [all|incomplete|completed] [date_due|priority]' if args.length > 2
            status = args[0]
            if status == 'all'
                status = nil
            end
            tasks = @task_list.list(status: status, sort_by: args[1])
            output.puts('No tasks.') if tasks.empty?
            tasks.each do |task|
                mark = ''
                if @task_list.stale?(task)
                    mark = ' [stale]'
                end
                output.puts("#{task['id']}: #{task['title']} | #{task['priority']} | #{task['date_due']} | #{task['status']}#{mark}")
            end
        when 'add'
            raise ArgumentError, 'usage: add TITLE PRIORITY DATE' unless args.length == 3
            id = @task_list.add(args[0], args[1], args[2])
            @storage.save(@task_list.list) if @storage
            output.puts("Task #{id} added.")
        when 'complete', 'delete'
            raise ArgumentError, "usage: #{command} ID" unless args.length == 1
            id = Integer(args[0], 10)
            if command == 'complete'
                @task_list.complete(id)
            else
                @task_list.delete(id)
            end
            @storage.save(@task_list.list) if @storage
            if command == 'complete'
                output.puts('Task completed.')
            else
                output.puts('Task deleted.')
            end
        when 'edit'
            raise ArgumentError, 'usage: edit ID title|priority|date_due VALUE' unless args.length == 3 && ['title', 'priority', 'date_due'].include?(args[1])
            id = Integer(args[0], 10)
            if args[1] == 'title'
                @task_list.edit(id, title: args[2])
            elsif args[1] == 'priority'
                @task_list.edit(id, priority: args[2])
            else
                @task_list.edit(id, date_due: args[2])
            end
            @storage.save(@task_list.list) if @storage
            output.puts('Task updated.')
        else
            raise ArgumentError, 'commands: add, list, edit, complete, delete'
        end
        0
    rescue ArgumentError, Storage::Error => error
        output.puts("Error: #{error.message}")
        1
    end
end

def add(title, priority, date_due)
    storage = Storage.new(ENV.fetch('PROFRESH_DATA_FILE', File.expand_path('../data/task_list.json', __dir__)))
    tasks = TaskList.new(storage.load)
    id = tasks.add(title, priority, date_due)
    storage.save(tasks.list)
    id
end

exit(ProFresh.new.run(ARGV)) if $PROGRAM_NAME == __FILE__
