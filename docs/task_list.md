# TaskList (Stories 5, 7, and 8)

Run the tests with `rspec spec/task_list_spec.rb`.

Load `lib/task_list.rb` and pass the task array from `parsed_json['tasks']`
to `TaskList.new`. Tasks use the string keys in `spec/main_spec.rb`, ISO8601
dates, integer IDs, and the statuses `incomplete` and `completed`.

```ruby
require_relative 'lib/task_list'

tasks = TaskList.new(parsed_json['tasks'])
tasks.list(status: 'incomplete', sort_by: 'date_due')
tasks.list(sort_by: 'priority')
tasks.complete(1)
tasks.delete(1)
```

`list` returns task hashes without changing the stored order. `complete` and
`delete` update the supplied array. Missing IDs raise `ArgumentError` with
`task not found`. Completing a task again preserves its finish date.

The CLI needs to display returned tasks and errors and convert input IDs to
integers. The storage code needs to save the array after successful changes.
These connections still need to be tested with the teammate's implementation.
The existing add tests depend on an `add` implementation that is not present
in this checkout.

## Story 6

`TaskList#stale?` marks incomplete tasks last updated at least 14 calendar days
ago. `ProFresh#run` displays `[stale]` in list output. Editing a title, priority,
or due date validates the input before refreshing `updated`; completed tasks
never show the mark. Dates follow the existing ISO8601 storage convention.
Run `rspec spec/stale_spec.rb` for boundary, validation, and display tests.
