# System Design: Profresh Task Manager

## System Architecture

### Task
Represents a single task.  Stores the task ID, title, priority, status, and the created/updated/finished timestamps.

### TaskList
Stores Tasks.  Tasks can be added, deleted, edited, filtered, searched, and sorted.

### Storage
Reads and writes the JSON file.  It also handles the case when the file is missing or broken.

### CLI
Handles the commands from the user, checks if the input is correct, and display of menu or error messages

## User Interface Design
```
-- ProFresh Task Manager --
1. List tasks
2. Add task
3. Edit task
4. Add tag to task
5. Remove tag from task
6. Clear tags from task
7. Complete task
8. Delete task
9. Exit
```
### Mock-ups
Mockups show option entered, prompts after option selected, and output result/message.  First mock-up uses example data.

```
1
Filter status (all/incomplete/completed) [all]: 
Sort by (date_due/priority) [none]: 
1: write code | Priority: high | Due: 2026-09-26 | Status: incomplete | Tags:  | Created: 2026-09-28 | Updated: 2026-09-28 | Finished: 
```
```
2
Title: write code 
Priority (high/medium/low): high
Due Date (M/D/YYYY or YYYY-MM-DD): 9/26/2026
Task 1 added.
```
```
3
Task ID: 1
Field to edit (title/priority/date_due): priority
New value: low
Task updated.
```
```
4
Task ID: 1
Tag name: CSCE 606
Tag 'CSCE 606' added to task 1.
```
```
5
Task ID: 1
Tag name: CSCE 606
Tag 'CSCE 606' removed from task 1.
```
```
6
Task ID: 1
All tags cleared for task 1.
```
```
7
Task ID to complete: 1
Task completed.
```
```
8
Task ID to delete: 1
Task deleted.
```
```
9
Goodbye!
```

### Key Workflows & Interactions

#### App Startup And Data Load Sequence
1. User executes CLI application
2. Storage.load searches for task_list.json.
   - If file exists and valid: Reads JSON array, reconstructs Task object, populates TaskList.
   - If file does not exist: Initializes an empty TaskList, creates task_list.json.
3. CLI main menu loop launches.

### Design Decisions

#### Separation of Presentation and Business Logic
Isolates the CLI (/bin/cli.rb) and business logic (/lib/*) and testing (/spec/*)

#### Usage of ISO8601 for timestamps
All dates use a standardised ISO8601 format for timestamps ensuring reliable sorting and math operations.

#### Dynamic Stale Mark
Stale marker is computed dynamically (current - updated >= 14 days) rather than storing it as a boolean hardcoded flag.  This ensures the marker is always up-to-date.
