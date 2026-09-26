require_relative '../bin/cli'
require 'stringio'

# Menu Mock-up - just a start, change as needed
# display title
# 1 List tasks
# 2 add tasks
# 3 edit tasks
# 4 add tag
# 5 remove tag
# 6 clear all tags
# 7 complete task
# 8 delete task
# 9 exit

describe 'CLI' do

    let(:output) { StringIO.new }
    let(:mock_app) { instance_double('ProFresh') }
    subject(:cli) { CLI.new(mock_app) }

    # Helper to simulate user inputs
    def simulated_input(*inputs)

        StringIO.new(inputs.join("\n") + "\n")

    end

    describe '#start' do

        it 'displays the menu and exits when option 9 is selected' do

            input = simulated_input('9')

            cli.start(input: input, output: output)

            expect(output.string).to include('-- ProFresh Task Manager --')
            expect(output.string).to include('Goodbye!')
            
        end

    end

    describe 'option 1 selected' do

        it 'delegates to @app.run' do

            input = simulated_input('1', 'incomplete', 'priority', '9')

            expect(mock_app).to receive(:run).with(['list', 'incomplete', 'priority'], output: output)

            cli.start(input: input, output: output)

        end

        it 'displays full list' do

            input = simulated_input('1', '', '', '9')

            expect(mock_app).to receive(:run).with(['list', 'all'], output: output)

            cli.start(input: input, output: output)

        end

    end

    describe 'options 2 - 8 selected' do

        it 'delegates to @app.run when option 2 is selected' do

            input = simulated_input('2', 'Write Unit Tests', 'high', '2026-10-01', '9')

            expect(mock_app).to receive(:run).with(['add', 'Write Unit Tests', 'high', '2026-10-01'], output: output)

            cli.start(input: input, output: output)

        end

        it 'delegates to @app.run when option 3 is selected' do

            input = simulated_input('3', '1', 'priority', 'medium', '9')

            expect(mock_app).to receive(:run).with(['edit', '1', 'priority', 'medium'], output: output)

            cli.start(input: input, output: output)

        end

        it 'calls #add_tag when option 4 is selected' do

            input = simulated_input('4', '1', 'CSCE 606', '9')

            expect(cli).to receive(:add_tag).with(1, 'CSCE 606').and_return(nil)

            cli.start(input: input, output: output)
            expect(output.string).to include("Tag 'CSCE 606' added to task 1.")

        end

        it 'calls #remove_tag when option 5 is selected' do

            input = simulated_input('5', '1', 'CSCE 606', '9')

            expect(cli).to receive(:remove_tag).with(1, 'CSCE 606').and_return(nil)

            cli.start(input: input, output: output)
            expect(output.string).to include("Tag 'CSCE 606' removed from task 1.")

        end

        it 'calls #clear_tags when option 6 is selected' do

            input = simulated_input('6', '1', '9')

            expect(cli).to receive(:clear_tags).with(1).and_return(nil)

            cli.start(input: input, output: output)
            expect(output.string).to include('All tags cleared for task 1.')

        end

        it 'delegates to @app.run when option 7 is selected' do

            input = simulated_input('7', '1', '9')

            expect(mock_app).to receive(:run).with(['complete', '1'], output: output)

            cli.start(input: input, output: output)

        end

        it 'delegates to @app.run when option 8 is selected' do 

            input = simulated_input('8', '1', '9')

            expect(mock_app).to receive(:run).with(['delete', '1'], output: output)

            cli.start(input: input, output: output)

        end

    end

    describe 'Handles errors/exceptions' do

        it 'handles invalid menu selections' do

            input = simulated_input('invalid_option', '9')

            cli.start(input: input, output: output)

            expect(output.string).to include('Invalid choice. Please enter a number between 1 and 9.')

        end

        it 'catches StandardError exceptions' do

            input = simulated_input('2', '', '', '', '9')

            allow(mock_app).to receive(:run).and_raise(StandardError, 'title cannot be empty')

            cli.start(input: input, output: output)

            expect(output.string).to include('Error: title cannot be empty')

        end

    end

end