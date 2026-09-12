require_relative '../lib/profresh'

describe 'adding new task' do

    describe '#add' do
        it 'should be defined' do
            title = "write code"
            priority = "high"
            date_due = "9/26/2026"
            tags = [""]
            expect {add(title, priority, date_due, tags)}.not_to raise_error
        end
    end

end