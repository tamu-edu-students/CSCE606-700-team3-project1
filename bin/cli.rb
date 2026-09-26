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

                when '9', 'exit', 'quit'
                    output.puts "Goodbye!"
                    break

            end

        end

    end

end
