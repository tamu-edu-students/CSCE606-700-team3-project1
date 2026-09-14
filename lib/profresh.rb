require 'json'
require 'date'

DATA_PATH = File.join(__dir__, '..', 'data', 'task_list.json')

def load_data

    return {'tasks' => []} unless File.exist?(DATA_PATH)
    content = File.read(DATA_PATH)
    return {'tasks' => []} if content.strip.empty?

    JSON.parse(content)

end

def save_data(data)

    dir = File.dirname(DATA_PATH)
    Dir.mkdir(dir) unless Dir.exist?(dir)
    File.write(DATA_PATH, JSON.pretty_generate(data))

end

def parse_to_iso8601(date_str)

    return "" if date_str.nil? || date_str.strip.empty?

    Date.strptime(date_str, '%m/%d/%Y').iso8601

    rescue ArgumentError

    Date.parse(date_str).iso8601

end

def add_task(title, priority, date_due)

    data = load_data
    tasks = data['tasks']

    new_id = (tasks.map {|task| task['id']}.max || 0) + 1
    today_iso = Date.today.iso8601

    new_task = {
        'id' => new_id,
        'title' => title,
        'priority' => priority,
        'date_due' => parse_to_iso8601(date_due),
        'tags' => [],
        'status' => 'pending',
        'created' => today_iso,
        'updated' => today_iso,
        'finished' => ''
    }

    tasks << new_task
    save_data(data)
    new_id

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
        task['priority'] = priority
        task['updated'] = Date.today.iso8601
        save_data(data)
    end

end

def edit_date_due(id, date)

    data = load_data
    task = data['tasks'].find {|task| task['id'] == id}

    if task
        task['date_due'] = date
        task['updated'] = Date.today.iso8601
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
        command, *args = arguments
        case command
        when 'list'
            raise ArgumentError, 'usage: list [all|incomplete|completed] [date_due|priority]' if args.length > 2
            tasks = @task_list.list(status: args[0] == 'all' ? nil : args[0], sort_by: args[1])
            output.puts('No tasks.') if tasks.empty?
            tasks.each do |task|
                mark = @task_list.stale?(task) ? ' [stale]' : ''
                output.puts("#{task['id']}: #{task['title']} | #{task['priority']} | #{task['date_due']} | #{task['status']}#{mark}")
            end
        when 'add'
            raise ArgumentError, 'usage: add TITLE PRIORITY DATE' unless args.length == 3
            id = @task_list.add(*args)
            @storage.save(@task_list.list) if @storage
            output.puts("Task #{id} added.")
        when 'complete', 'delete'
            raise ArgumentError, "usage: #{command} ID" unless args.length == 1
            @task_list.public_send(command, Integer(args[0], 10))
            @storage.save(@task_list.list) if @storage
            output.puts(command == 'complete' ? 'Task completed.' : 'Task deleted.')
        when 'edit'
            raise ArgumentError, 'usage: edit ID title|priority|date_due VALUE' unless args.length == 3 && ['title', 'priority', 'date_due'].include?(args[1])
            @task_list.edit(Integer(args[0], 10), **{ args[1].to_sym => args[2] })
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

# Keep the original add API used by the project tests.
def add(title, priority, date_due)
    storage = Storage.new(ENV.fetch('PROFRESH_DATA_FILE', File.expand_path('../data/task_list.json', __dir__)))
    tasks = TaskList.new(storage.load)
    id = tasks.add(title, priority, date_due)
    storage.save(tasks.list)
    id
end

exit(ProFresh.new.run(ARGV)) if $PROGRAM_NAME == __FILE__
