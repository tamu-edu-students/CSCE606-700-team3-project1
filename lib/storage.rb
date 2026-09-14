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
        validate(data['tasks'])
        data['tasks']
    rescue JSON::ParserError
        raise Error, 'invalid JSON in task file'
    rescue SystemCallError => error
        raise Error, "cannot read task file: #{error.message}"
    end

    def save(tasks)
        validate(tasks)
        # Refuse to overwrite an existing unreadable or invalid file.
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

    def validate(tasks)
        ids = []
        tasks.each do |task|
            valid = task.is_a?(Hash) && task['id'].is_a?(Integer) && task['id'] > 0 &&
                    !ids.include?(task['id']) && task['title'].is_a?(String) &&
                    !task['title'].strip.empty? && ['low', 'medium', 'high'].include?(task['priority']) &&
                    ['incomplete', 'completed'].include?(task['status']) &&
                    task['tags'].is_a?(Array) && task['tags'].all? { |tag| tag.is_a?(String) }
            raise Error, 'invalid task data' unless valid
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
