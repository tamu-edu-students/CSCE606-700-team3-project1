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

def edit_priority(id, priority)

    data = load_data
    task = data['tasks'].find {|task| task['id'] == id}

    if task
        task['priority'] = priority
        task['updated'] = Date.today.iso8601
        save_data(data)
    end

end