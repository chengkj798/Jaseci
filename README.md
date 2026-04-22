# AI Day Planner with Priority Levels

**UMID:** chengkj

## Project Overview

This project is based on the official Jac **Build an AI Day Planner** tutorial and includes the full application flow:

- task CRUD
- AI-powered task categorization
- AI-generated meal shopping lists
- authentication / per-user data isolation
- walker-based backend logic

I also added one custom feature for the assignment:

## Custom Feature: Priority Levels

Each task now has a **priority level**:

- `high`
- `medium`
- `low`

Users can choose a priority when creating a task. The app then:

- stores that priority on the `Task` node
- shows a visual priority badge for each task
- displays tasks in priority order (`high -> medium -> low`)

This makes the task list more useful for actual day planning instead of treating every task the same.

## Files

- `main.jac`
  - task and shopping list nodes
  - AI categorization and shopping list generation
  - walker-based task and shopping list operations
  - priority field added to `Task`
- `frontend.cl.jac`
  - UI, app state, auth screen, task input, meal planner UI
  - priority dropdown and priority badges
  - priority-based ordering in the task list
- `frontend.impl.jac`
  - method implementations that spawn walkers
  - passes selected priority into `AddTask`
- `styles.css`
  - application styling
  - added badge styles for high / medium / low priority
- `jac.toml`
  - project configuration
- `.env.example`
  - example environment variable file for Anthropic

## How to Run

### 1. Create a virtual environment

```bash
python -m venv jac-env
```

Activate it:

**Windows**
```bash
jac-env\Scripts\activate
```

**macOS / Linux**
```bash
source jac-env/bin/activate
```

### 2. Install Jac

```bash
pip install jaseci
jac --version
```

### 3. Set your Anthropic API key

**Windows (Command Prompt)**
```bash
set ANTHROPIC_API_KEY=your-key-here
```

**PowerShell**
```bash
$env:ANTHROPIC_API_KEY="your-key-here"
```

**macOS / Linux**
```bash
export ANTHROPIC_API_KEY="your-key-here"
```

### 4. Start the app

```bash
jac start --dev
```

### 5. Open in browser

Go to:

```text
http://localhost:8000/cl/app
```

## Notes

- This project follows the official Jac tutorial structure and then extends it with a custom feature.
- Authentication is handled with the built-in Jac runtime helpers in the frontend.
- Walkers are used for task and shopping list operations in the final version.
- If you upgrade Jac packages and run into weird cache issues, try:

```bash
jac purge
```

## Suggested Submission URL

Use this public GitHub repository URL for Canvas submission:

```text
https://github.com/chengkj798/Jaseci
```
