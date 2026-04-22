import from "@jac/runtime" { jacSignup, jacLogin, jacLogout, jacIsLoggedIn }
import "./styles.css";

sv import from .main {
    AddTodo,
    ListTodos,
    ToggleTodo,
    DeleteTodo,
    GenerateShoppingList,
    GetShoppingList,
    ClearShoppingList
}

def:pub app() -> JsxElement {
    has isLoggedIn: bool = False;
    has checkingAuth: bool = True;
    has isSignup: bool = False;
    has username: str = "";
    has password: str = "";
    has error: str = "";
    has loading: bool = False;

    has todos: list = [];
    has todoText: str = "";
    has todoPriority: str = "medium";
    has todosLoading: bool = True;

    has mealText: str = "";
    has ingredients: list = [];
    has generating: bool = False;

    can with entry {
        isLoggedIn = jacIsLoggedIn();
        checkingAuth = False;
    }

    async can with [isLoggedIn] entry {
        if isLoggedIn {
            await fetchTodos();
            await fetchShoppingList();
        }
    }

    async def fetchTodos() -> None {
        todosLoading = True;
        try {
            result = root() spawn ListTodos();
            if result.reports and result.reports.length > 0 {
                todos = result.reports[0];
            } else {
                todos = [];
            }
        } except Exception as e {
            error = "Failed to load todos: " + e;
            todos = [];
        }
        todosLoading = False;
    }

    async def addTodo() -> None {
        if not todoText.strip() {
            return;
        }

        try {
            result = root() spawn AddTodo(
                title=todoText.strip(),
                priority=todoPriority
            );
            if result.reports and result.reports.length > 0 {
                todos = todos + [result.reports[0]];
                todoText = "";
                todoPriority = "medium";
            }
        } except Exception as e {
            error = "Failed to add todo: " + e;
        }
    }

    async def toggleTodo(todo_id: str) -> None {
        try {
            result = root() spawn ToggleTodo(todo_id=todo_id);
            if result.reports and result.reports.length > 0 {
                updated = result.reports[0];
                todos = [updated if t.id == todo_id else t for t in todos];
            }
        } except Exception as e {
            error = "Failed to update todo: " + e;
        }
    }

    async def deleteTodo(todo_id: str) -> None {
        try {
            result = root() spawn DeleteTodo(todo_id=todo_id);
            if result.reports and result.reports.length > 0 {
                todos = [t for t in todos if t.id != todo_id];
            }
        } except Exception as e {
            error = "Failed to delete todo: " + e;
        }
    }

    async def handleSignup() -> None {
        loading = True;
        error = "";
        result = await jacSignup(username, password);
        if result["success"] {
            isLoggedIn = True;
            username = "";
            password = "";
        } else {
            error = result["error"] or "Signup failed";
        }
        loading = False;
    }

    async def handleLogin() -> None {
        loading = True;
        error = "";
        success = await jacLogin(username, password);
        if success {
            isLoggedIn = True;
            username = "";
            password = "";
        } else {
            error = "Login failed";
        }
        loading = False;
    }

    def handleLogout() -> None {
        jacLogout();
        isLoggedIn = False;
        todos = [];
        ingredients = [];
        error = "";
    }

    async def handleSubmit(e: FormEvent) -> None {
        e.preventDefault();
        if isSignup {
            await handleSignup();
        } else {
            await handleLogin();
        }
    }

    def handleTodoKeyPress(e: KeyboardEvent) -> None {
        if e.key == "Enter" {
            addTodo();
        }
    }

    async def fetchShoppingList() -> None {
        try {
            result = root() spawn GetShoppingList();
            if result.reports and result.reports.length > 0 {
                ingredients = result.reports[0];
            } else {
                ingredients = [];
            }
        } except Exception as e {
            error = "Failed to load shopping list: " + e;
            ingredients = [];
        }
    }

    async def generateList() -> None {
        if not mealText.strip() {
            return;
        }

        generating = True;
        error = "";
        try {
            result = root() spawn GenerateShoppingList(meal_description=mealText.strip());
            if result.reports and result.reports.length > 0 {
                ingredients = result.reports[0];
            } else {
                ingredients = [];
            }
        } except Exception as e {
            error = "Failed to generate shopping list: " + e;
        }
        generating = False;
    }

    async def clearList() -> None {
        try {
            result = root() spawn ClearShoppingList();
            if result.reports and result.reports.length > 0 {
                ingredients = [];
            }
        } except Exception as e {
            error = "Failed to clear shopping list: " + e;
        }
    }

    def handleMealKeyPress(e: KeyboardEvent) -> None {
        if e.key == "Enter" {
            generateList();
        }
    }

    def totalCost() -> float {
        total: float = 0.0;
        for ing in ingredients {
            total = total + ing.cost;
        }
        return total;
    }

    def formatMoney(value: float) -> str {
        return "$" + value.toFixed(2);
    }

    remainingCount = [t for t in todos if not t.done].length;
    orderedTodos = (
        [t for t in todos if t.priority == "high"] +
        [t for t in todos if t.priority == "medium"] +
        [t for t in todos if t.priority == "low"] +
        [t for t in todos if t.priority != "high" and t.priority != "medium" and t.priority != "low"]
    );

    if checkingAuth {
        return <div className="auth-loading">Loading...</div>;
    }

    if not isLoggedIn {
        return <div className="auth-page">
            <div className="auth-card">
                <h1>AI Day Planner</h1>
                <p className="auth-subtitle">
                    {isSignup and "Create an account" or "Sign in to continue"}
                </p>

                {error and <div className="error-box">{error}</div>}

                <form onSubmit={handleSubmit} className="auth-form">
                    <label className="form-label">Username</label>
                    <input
                        className="input"
                        type="text"
                        value={username}
                        onChange={lambda e: ChangeEvent { username = e.target.value; }}
                        placeholder="Enter username"
                    />

                    <label className="form-label">Password</label>
                    <input
                        className="input"
                        type="password"
                        value={password}
                        onChange={lambda e: ChangeEvent { password = e.target.value; }}
                        placeholder="Enter password"
                    />

                    <button className="primary-btn full-width" type="submit" disabled={loading}>
                        {loading and "Processing..." or (isSignup and "Create Account" or "Sign In")}
                    </button>
                </form>

                <div className="auth-switch">
                    <span>{isSignup and "Already have an account?" or "Need an account?"}</span>
                    <button
                        className="link-btn"
                        type="button"
                        onClick={lambda -> None {
                            isSignup = not isSignup;
                            error = "";
                        }}
                    >
                        {isSignup and "Sign In" or "Sign Up"}
                    </button>
                </div>
            </div>
        </div>;
    }

    return <div className="page">
        <div className="app-shell">
            <div className="app-header">
                <div>
                    <h1>AI Day Planner</h1>
                    <p className="app-subtitle">Todo manager + AI meal shopping list</p>
                </div>
                <button className="secondary-btn" onClick={handleLogout}>Sign Out</button>
            </div>

            {error and <div className="error-box">{error}</div>}

            <div className="grid-layout">
                <section className="panel">
                    <div className="panel-header">
                        <h2>Todos</h2>
                        <span className="muted-text">{remainingCount} remaining</span>
                    </div>

                    <div className="todo-input-row">
                        <input
                            className="input grow"
                            type="text"
                            value={todoText}
                            onChange={lambda e: ChangeEvent { todoText = e.target.value; }}
                            onKeyPress={handleTodoKeyPress}
                            placeholder="What needs to get done?"
                        />

                        <select
                            className="input priority-select"
                            value={todoPriority}
                            onChange={lambda e: ChangeEvent { todoPriority = e.target.value; }}
                        >
                            <option value="high">High</option>
                            <option value="medium">Medium</option>
                            <option value="low">Low</option>
                        </select>

                        <button className="primary-btn" onClick={lambda -> None { addTodo(); }}>
                            Add
                        </button>
                    </div>

                    {todosLoading and <div className="empty-state">Loading todos...</div>}

                    {!todosLoading and orderedTodos.length == 0 and <div className="empty-state">
                        No todos yet. Add your first one above.
                    </div>}

                    {!todosLoading and orderedTodos.length > 0 and <div className="todo-list">
                        {[
                            <div key={todo.id} className="todo-item">
                                <input
                                    type="checkbox"
                                    checked={todo.done}
                                    onChange={lambda -> None { toggleTodo(todo.id); }}
                                />
                                <div className="todo-main">
                                    <div className={todo.done and "todo-title done" or "todo-title"}>{todo.title}</div>
                                    <div className="todo-meta">
                                        <span className={"priority-badge priority-" + todo.priority}>{todo.priority}</span>
                                        <span className="category-badge">{todo.category}</span>
                                    </div>
                                </div>
                                <button className="danger-btn" onClick={lambda -> None { deleteTodo(todo.id); }}>
                                    Delete
                                </button>
                            </div>
                            for todo in orderedTodos
                        ]}
                    </div>}
                </section>

                <section className="panel">
                    <div className="panel-header">
                        <h2>Meal Shopping List</h2>
                        <span className="muted-text">AI generated</span>
                    </div>

                    <div className="todo-input-row">
                        <input
                            className="input grow"
                            type="text"
                            value={mealText}
                            onChange={lambda e: ChangeEvent { mealText = e.target.value; }}
                            onKeyPress={handleMealKeyPress}
                            placeholder="Example: chicken stir fry for 4"
                        />
                        <button className="primary-btn" onClick={lambda -> None { generateList(); }} disabled={generating}>
                            {generating and "Generating..." or "Generate"}
                        </button>
                    </div>

                    {ingredients.length == 0 and <div className="empty-state">
                        Enter a meal description to generate ingredients.
                    </div>}

                    {ingredients.length > 0 and <div className="shopping-list">
                        {[
                            <div key={item.id} className="ingredient-item">
                                <div>
                                    <div className="ingredient-name">{item.name}</div>
                                    <div className="ingredient-meta">{item.quantity} {item.unit}</div>
                                </div>
                                <div className="ingredient-right">
                                    {item.carby and <span className="carb-badge">Carbs</span>}
                                    <span className="ingredient-cost">{formatMoney(item.cost)}</span>
                                </div>
                            </div>
                            for item in ingredients
                        ]}

                        <div className="shopping-footer">
                            <span className="total-cost">Total: {formatMoney(totalCost())}</span>
                            <button className="secondary-btn" onClick={lambda -> None { clearList(); }}>
                                Clear
                            </button>
                        </div>
                    </div>}
                </section>
            </div>
        </div>
    </div>;
}
