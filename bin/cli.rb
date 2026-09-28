require_relative '../lib/profresh'

class CLI

    def initialize(app = ProFresh.new)
        @app = app
    end

    def start(input: $stdin, output: $stdout)

        loop do

            output.puts "\n-- ProFresh Task Manager --"
            output.puts "1. List tasks"
            output.puts "2. Add task"
            output.puts "3. Edit task"
            output.puts "4. Add tag to task"
            output.puts "5. Remove tag from task"
            output.puts "6. Clear tags from task"
            output.puts "7. Complete task"
            output.puts "8. Delete task"
            output.puts "9. Exit"

            choice = input.gets&.strip

            case choice

                when '1'
                    output.print "Filter status (all/incomplete/completed) [all]: "
                    status = input.gets.strip
                    status = 'all' if status.empty?
                    output.print "Sort by (date_due/priority) [none]: "
                    sort_by = input.gets.strip
                    sort_by = nil if sort_by.empty?
                    args = ['list', status]
                    args << sort_by if sort_by
                    @app.run(args, output: output)

                when '2'
                    output.print "Title: "
                    title = input.gets.strip
                    output.print "Priority (high/medium/low): "
                    priority = input.gets.strip
                    output.print "Due Date (M/D/YYYY or YYYY-MM-DD): "
                    date_due = input.gets.strip
                    @app.run(['add', title, priority, date_due], output: output)

                when '3'
                    output.print "Task ID: "
                    id = input.gets.strip
                    output.print "Field to edit (title/priority/date_due): "
                    field = input.gets.strip
                    output.print "New value: "
                    value = input.gets.strip
                    @app.run(['edit', id, field, value], output: output)

                when '4'
                    output.print "Task ID: "
                    id = Integer(input.gets.strip, 10)
                    output.print "Tag name: "
                    tag = input.gets.strip
                    add_tag(id, tag)
                    output.puts "Tag '#{tag}' added to task #{id}."

                when '5'
                    output.print "Task ID: "
                    id = Integer(input.gets.strip, 10)
                    output.print "Tag name: "
                    tag = input.gets.strip
                    remove_tag(id, tag)
                    output.puts "Tag '#{tag}' removed from task #{id}."

                when '6'
                    output.print "Task ID: "
                    id = Integer(input.gets.strip, 10)
                    clear_tags(id)
                    output.puts "All tags cleared for task #{id}."

                when '7'
                    output.print "Task ID to complete: "
                    id = input.gets.strip
                    @app.run(['complete', id], output: output)

                when '8'
                    output.print "Task ID to delete: "
                    id = input.gets.strip
                    @app.run(['delete', id], output: output)

                when '9', 'exit', 'quit'
                    output.puts "Goodbye!"
                    break

            end

        end

    end

end