# System Design

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

### Mock-ups

### Key Workflows & Interactions

### Design Decisions
