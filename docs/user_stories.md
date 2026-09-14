# User Stories


## Story 1
As a User I want to Add a task called "write code", set its priority to high, and set the due date to "9/26/2026" so I can see it on my Task List to remind me I have to work on it.

__Acceptance Criteria__  
Given that I have entered the information correctly I see the task on my Task List with a priority set to high and the due date is "9/26/2026".

If a task list json file does not exist yet it will create the new list and new array of tasks.

## Story 2 (optional feature)
As a User I want to Add a "CSCE 606" tag to the "write code" task I have previously created so I know that it is a task for a specific class I am taking and be able to filter tasks by class later on but I delete the tag.

__Acceptance Criteria__  
Given that I have entered the information correctly and added the tag I see that there is a tag attached to the task "write code".

Given that I selected the correc tag I delete the tag and no longer see it associated with the task.

## Story 3 (Error)
As a User I want to Add a task called "write stories", I leave the priority set to medium, and set the due date to "14/9/2026" so I can see it on my Task List to remind me to work on it.

__Acceptance Criteria__  
Given that I have entered the date in an incorrect format I receive an error message stating that the date is was entered incorrectly.

Given that I change the date and enter it correctly as "9/14/2026" I see the task on my Task List.

## Story 4
As a User I want to Edit the priority and due_date of the "write stories" task and change it to a high priority and due "9/13/2026" since it is due soon so I can see that it must be worked on.

__Acceptance Criteria__  
Given that I have edited the correct task "write stories" from the Task List and changed the priority to a high priority I see that the task now shows "write stories" as a high priority.

## Story 5
As a User I want to View my Task List, filter tasks by completion status, and sort them by due date or priority so I can decide what to work on next.

__Acceptance Criteria__  
Given that I select a completion status and sort order I see only matching tasks on my Task List, with earlier due dates or higher priorities first.

## Story 6
As a User I want to See a stale mark on the "write code" task if I have not updated it for 14 days so I know I have forgotten to work on it.

__Acceptance Criteria__  
Given that the task "write code" is incomplete and has not been updated for at least 14 days I see a stale mark on it, and after I edit the task the stale mark is removed.

## Story 7
As a User I want to Complete the task "write code" by its ID so I can keep track of the work I have finished.

__Acceptance Criteria__  
Given that I complete the correct task "write code" I see that its status is completed, its finish time is recorded, and it no longer appears when I filter for incomplete tasks.

## Story 8
As a User I want to Delete the task "write code" by its ID so I can remove a task I no longer need from my Task List.

__Acceptance Criteria__  
Given that I enter the correct ID the task is removed and other tasks remain unchanged, and if the ID does not exist I receive a "task not found" error without changing my Task List.

## Story 9
As a User I want to Save my tasks into a JSON file and load them when I open the app again so I do not lose my work.

__Acceptance Criteria__  
Given that I make changes to my tasks and reopen the app I see the same saved tasks and information, with an empty list if the file is missing or a clear error if the JSON is invalid.

## Story 10
As a User I want to clear all tags from a task by its ID so that I can reset the categorization of a task without deleting tags individually.

__Acceptance Criteria__  
Given a valid task ID, calling clear_tags(id) removes all items from the task’s tags array (setting it back to []) and updates the updated timestamp.

Given a task that already has no tags, calling clear_tags(id) leaves the empty tags array unchanged and does not raise an error.