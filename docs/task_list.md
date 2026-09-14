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

## Story 6

`TaskList#stale?` marks incomplete tasks last updated at least 14 calendar days
ago. `ProFresh#run` displays `[stale]` in list output. Editing a title, priority,
or due date validates the input before refreshing `updated`; completed tasks
never show the mark. Dates follow the existing ISO8601 storage convention.
Run `rspec spec/stale_spec.rb` for boundary, validation, and display tests.

## Story 9

Run `ruby lib/profresh.rb` with the commands below. The app loads the JSON file
at startup and saves successful add, edit, complete, and delete operations.
The default file is `data/task_list.json`; set `PROFRESH_DATA_FILE` to use another
path. The file contains a `tasks` array, preserving task fields and tags.
Missing files start empty. Invalid JSON or task data produces an error and is
not overwritten. Saves replace the file only after a temporary file is fully
written. Concurrent writers are not supported; run one command at a time.

```sh
ruby lib/profresh.rb add "write code" high 9/26/2026
ruby lib/profresh.rb list incomplete priority
ruby lib/profresh.rb edit 1 priority medium
ruby lib/profresh.rb edit 1 date_due 2026-09-28
ruby lib/profresh.rb complete 1
ruby lib/profresh.rb delete 1
```

Titles containing spaces must be quoted. IDs are integers. Input dates accept
M/D/YYYY or YYYY-MM-DD and are saved as YYYY-MM-DD. `list all date_due` sorts
all tasks by due date. Failed commands print `Error:` and exit with status 1.
New IDs are greater than every currently saved ID. Stale marks are calculated
when listing, so they do not need to be stored.

Run `rspec` for all tests, including separate-process persistence tests in
`spec/storage_spec.rb`. Tests use temporary files and do not modify user data.
Stories 6 and 9 are implemented locally; story point estimates and team tracker
status still need to be agreed with the team.

## Integration with the merged task APIs

`add_task`, `add_tag`, `remove_tag`, `clear_tags`, `edit_priority`, and
`edit_date_due` share the CLI's storage and `PROFRESH_DATA_FILE` setting.
Edited due dates are saved as ISO8601, matching newly added tasks.
Existing `pending` tasks load as `incomplete`, and M/D/YYYY due dates load as
ISO8601. Reading does not rewrite the file; the next successful change saves
the normalized values. IDs, tags, and timestamps are preserved on loading.
Run `rspec spec/integration_spec.rb` to check compatibility between these APIs,
legacy task files, and the CLI. All tests use temporary task files.
