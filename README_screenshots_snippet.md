# AI Day Planner with Priority Levels

**Name:** [Add your full name here]  
**UMID:** chengkj

## Project Overview

This project is based on the official Jac **Build Your First App** tutorial flow. It includes:

- todo CRUD
- AI-based todo categorization
- user authentication
- AI-generated meal shopping lists
- a clean multi-file project structure

## Custom Feature Added

I added **priority levels** for todo items.

Each todo can now be assigned one of three priority levels:

- high
- medium
- low

The app stores the priority on each todo, shows a visible priority badge, and renders todos in priority order.

## Where the Feature Is Implemented

- `main.jac`
  - Added the `priority` field to the `Todo` node
  - Updated the `AddTodo` walker to save the selected priority
- `frontend.cl.jac`
  - Added a priority dropdown when creating a todo
  - Added priority badges in the UI
  - Added priority-based ordering of the todo list
- `styles.css`
  - Added badge styles for high / medium / low priority

## Project Files

- `main.jac` - server logic, AI functions, walkers
- `frontend.cl.jac` - client UI and app logic
- `frontend.impl.jac` - placeholder extra file for clean multi-file structure
- `styles.css` - app styles
- `jac.toml` - Jac project config
- `.env.example` - example API key file

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

- The tutorial uses Jac's `by llm()` integration for AI features.
- The app uses authenticated private walkers for per-user todo isolation.
- Before submitting, replace the name placeholder at the top of this README.
## Screenshots

### 1. Login page
The application includes a sign-in / sign-up screen so each user can manage a separate planner account.

![Login page](assets/01_login_page.png)

### 2. Todo creation
Users can create new todo items from the main dashboard. The app supports standard todo CRUD functionality from the tutorial workflow.

![Todo creation](assets/02_todo_added.png)

### 3. Priority levels feature
This is the custom feature I added. Each todo can be assigned a high, medium, or low priority. The UI shows a visible priority badge and renders todos in priority order.

![Priority levels](assets/03_priority_levels.png)

### 4. AI-generated shopping list
The app also supports AI-based meal planning. After entering a meal description, the app generates a shopping list with ingredient quantities, estimated cost, and carbohydrate tags.

![AI shopping list](assets/04_ai_shopping_list.png)
