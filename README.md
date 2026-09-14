# ProFresh
**CSCE Software Engineering 606-700 - Team 3 Project 1**

## Team Members:
1. Yuhang Zhou
2. Adam Harrison

## Description
ProFresh is a task tracker that keeps your todo list fresh. It saves your tasks with a priority and a due date, and it also remembers the last time you touched each task, so if one task is not updated for a long time, the app marks it as "stale" and you can see which task you forgot.

## Intended User
Busy individuals who have too many tasks every day and want a convenient tool to have them kept track of.

## Core Features
1. **Add** a task.  The user give a title, a priority (low/medium/high), and a due date.
2. **List** the tasks.  The user can filter them and sort them by due date, or by priority.  Old tasks are shown with a "stale mark.
3. **Complete** a task and delete it by its ID.  When a task is completed the finish time will be recorded.
4. **Edit** a task.  The user can change the title, the priority, or the due date.  After an edit the task becomes fresh again.
5. **Save** all the tasks into a JSON file and load them again, so the tasks are still there next time the user opens the app.

## Stretch Features
1. Add tags to a task, then the user can group and filter the tasks by tag.
2. A summery command that shows how many tasks are complete, incomplete, late, and how many tasks were finished in the last day or week.
3. Repeating tasks. After the user completes them, they come back again.

## Main Classes/Modules
1. **Task**: one single task.  It keeps the ID, title, priority, due date, and the created/updated/finished time.  It can also tell if it is late or stale.
2. **TaskList**: it keeps all the tasks together.  It can add, delete, edit, complete, find by id, filter, and sort.
3. **Storage**: it reads and writes the JSON file.  It also handles the case when the file is missing or broken.
4. **CLI**: if reads the command from the user, checks if the input is correct, and prints the table of the error message.

## Test Cases
1. **Add a task**
  + Start with no task. Add "write essay" with the priority high.  Expect the list has 1 task, the title is "write essay", it is not done, and it gets an ID.
  + Add a task with priority "urgent". Expect an error message, and no task is added.
2. **List/Filter/Stale**
  + One task is due yesterday and one task is due next week. Sort by due date. Expect yesterday’s task first and it is marked as late.
  + One task was updated 30 days ago and the stale limit is 14 days. List the tasks. Expect this task is marked as stale.
3. **Complete and Delete**
  + Complete the task with id 1. Expect it is done and it has a finish time.  When we list the not done tasks, it should not be there.
  + Delete id 99, but the list only has id 1. Expect an error "task not found", and the list does not change.
4. **Edit a task**
  + Change the due date of task 1 to a correct date. Expect the new due date is saved and the updated time is new, so the task is not stale now.
  + Change the due date of task 1 to "2025/13/45". Expect a date format error, and the task does not change.
5. **Save and Load**
  + Add 2 tasks and save. Then load the file again. Expect the same 2 tasks, with the same id, title, and status.
  + Load a file that does not exist. Expect an empty list and no crash. Load a broken JSON file. Expect a clear error message.

## Running the app

Run `ruby lib/profresh.rb add "write code" high 9/26/2026`, then
`ruby lib/profresh.rb list`. Tasks are saved in `data/task_list.json`.
See [TaskList usage](docs/task_list.md) for editing, completion, deletion,
filters, stale marks, and storage behavior. Run `rspec` to run the tests.
