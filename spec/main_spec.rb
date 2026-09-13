require_relative '../lib/profresh'

describe 'adding new task' do

    describe '#add' do

        # Story 1 ------------------------------------------------------------

        it 'should be defined' do
            title = "write code"
            priority = "high"
            date_due = "9/26/2026"
            tags = [""]
            expect {add(title, priority, date_due, tags)}.not_to raise_error
        end

        # it 'creates json file if it doesn't exist yet'
            # expect file to exist

        # it 'is stored correctly into json file'
            # expect title = title
            # expect priority = priority
            # etc... to include timestamps, status, and id

        # --------------------------------------------------------------------

        # Story 3 ------------------------------------------------------------

        # it 'properly handles date input'
            # expect obviously incorrect date to raise error

        # it 'stores date in proper format'
            # expect date stored in the proper format: ISO 8601'

        # --------------------------------------------------------------------

    end


    # describe '#add_tag'

        # Story 2 ------------------------------------------------------------

        # it 'should be defined'
            # expect not to raise error

        # it 'has tag for correct task'
            # expect to be true
            # expect to eq 'CSCE 606'

        # --------------------------------------------------------------------


    # describe '#edit'

        # Story 4 ------------------------------------------------------------

        # it 'should be defined'
            # expect not to raise error

        # it 'properly saves changes'
            # expect priority to eq 'high'

        # --------------------------------------------------------------------

end