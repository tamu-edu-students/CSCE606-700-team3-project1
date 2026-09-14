require 'json'
require 'date'
require 'fileutils'
require 'tempfile'

class Storage
    class Error < StandardError; end

    def initialize(path)
        @path = File.expand_path(path)
    end

    def load
        return [] unless File.exist?(@path)

        data = JSON.parse(File.read(@path))
        raise Error, 'invalid task file: expected a tasks array' unless data.is_a?(Hash) && data['tasks'].is_a?(Array)
        normalize(data['tasks'])
        validate(data['tasks'])
        data['tasks']
    rescue JSON::ParserError
        raise Error, 'invalid JSON in task file'
    rescue SystemCallError => error
        raise Error, "cannot read task file: #{error.message}"
    end

    def save(tasks)
        validate(tasks)
        load
        directory = File.dirname(@path)
        FileUtils.mkdir_p(directory)
        Tempfile.create(['.tasks-', '.json'], directory) do |file|
            file.write(JSON.pretty_generate('tasks' => tasks))
            file.flush
            file.fsync
            File.rename(file.path, @path)
        end
    rescue SystemCallError => error
        raise Error, "cannot save task file: #{error.message}"
    end

    private

    def normalize(tasks)
        for task in tasks
            next unless task.is_a?(Hash)
            if task['status'] == 'pending'
                task['status'] = 'incomplete'
            end
            date = task['date_due']
            if date.is_a?(String) && date.match?(/\A\d{1,2}\/\d{1,2}\/\d{4}\z/)
                task['date_due'] = Date.strptime(date, '%m/%d/%Y').iso8601
            end
        end
    rescue ArgumentError
        raise Error, 'invalid task date'
    end

    def validate(tasks)
        ids = []
        tasks.each do |task|
            if !task.is_a?(Hash)
                raise Error, 'invalid task data'
            end
            if !task['id'].is_a?(Integer) || task['id'] <= 0 || ids.include?(task['id'])
                raise Error, 'invalid task data'
            end
            if !task['title'].is_a?(String) || task['title'].strip.empty?
                raise Error, 'invalid task data'
            end
            if task['priority'] != 'low' && task['priority'] != 'medium' && task['priority'] != 'high'
                raise Error, 'invalid task data'
            end
            if task['status'] != 'incomplete' && task['status'] != 'completed'
                raise Error, 'invalid task data'
            end
            if !task['tags'].is_a?(Array)
                raise Error, 'invalid task data'
            end
            for tag in task['tags']
                if !tag.is_a?(String)
                    raise Error, 'invalid task data'
                end
            end
            ids << task['id']
            ['date_due', 'created', 'updated', 'finished'].each do |field|
                value = task[field]
                next if field == 'finished' && value == '' && task['status'] == 'incomplete'
                unless value.is_a?(String) && value.match?(/\A\d{4}-\d{2}-\d{2}\z/)
                    raise Error, "invalid task date: #{field}"
                end
                Date.iso8601(value)
            end
        end
    rescue ArgumentError
        raise Error, 'invalid task date'
    end
end
