"""AI Day Planner with priority levels."""

cl import from .frontend { app as ClientApp }

cl def:pub app() -> JsxElement {
    return <ClientApp />;
}

import from byllm.lib { Model }
import from uuid { uuid4 }

glob llm = Model(model_name="claude-sonnet-4-20250514");

enum Category { WORK, PERSONAL, SHOPPING, HEALTH, OTHER }
enum Unit { PIECE, LB, OZ, CUP, TBSP, TSP, CLOVE, BUNCH, CAN, PACK }

obj Ingredient {
    has name: str;
    has quantity: float;
    has unit: Unit;
    has cost: float;
    has carby: bool;
}

sem Ingredient.cost = "Estimated cost in USD";
sem Ingredient.carby = "True if this ingredient is high in carbohydrates";

def categorize(title: str) -> Category by llm();
sem categorize = "Categorize a todo item based on its title";

def generate_ingredients(meal_description: str) -> list[Ingredient] by llm();
sem generate_ingredients = "Generate a grocery list for a meal description";

node Todo {
    has id: str = str(uuid4()),
        title: str,
        done: bool = False,
        category: str = "other",
        priority: str = "medium";
}

node MealIngredient {
    has id: str = str(uuid4()),
        name: str,
        quantity: float,
        unit: str,
        cost: float,
        carby: bool;
}

walker:priv AddTodo {
    has title: str;
    has priority: str = "medium";

    can create with Root entry {
        category = str(categorize(self.title)).split(".")[-1].lower();
        priority_value = self.priority.lower().strip();

        if priority_value != "high" and priority_value != "medium" and priority_value != "low" {
            priority_value = "medium";
        }

        new_todo = here ++> Todo(
            title=self.title,
            category=category,
            priority=priority_value
        );
        report new_todo[0];
    }
}

walker:priv ListTodos {
    has results: list = [];

    can start with Root entry {
        visit [-->];
    }

    can collect with Todo entry {
        self.results.append(here);
    }

    can done with Root exit {
        report self.results;
    }
}

walker:priv ToggleTodo {
    has todo_id: str;

    can search with Root entry {
        visit [-->];
    }

    can toggle with Todo entry {
        if here.id == self.todo_id {
            here.done = not here.done;
            report here;
            disengage;
        }
    }
}

walker:priv DeleteTodo {
    has todo_id: str;

    can search with Root entry {
        visit [-->];
    }

    can delete with Todo entry {
        if here.id == self.todo_id {
            removed_id = here.id;
            del here;
            report {"deleted": removed_id};
            disengage;
        }
    }
}

walker:priv GenerateShoppingList {
    has meal_description: str;

    can generate with Root entry {
        visit [-->];

        ingredients = generate_ingredients(self.meal_description);
        result: list = [];

        for ing in ingredients {
            unit_value = str(ing.unit).split(".")[-1].lower();
            new_item = here ++> MealIngredient(
                name=ing.name,
                quantity=ing.quantity,
                unit=unit_value,
                cost=ing.cost,
                carby=ing.carby
            );
            result.append(new_item[0]);
        }

        report result;
    }

    can clear_old with MealIngredient entry {
        del here;
    }
}

walker:priv GetShoppingList {
    has items: list = [];

    can start with Root entry {
        visit [-->];
    }

    can collect with MealIngredient entry {
        self.items.append(here);
    }

    can done with Root exit {
        report self.items;
    }
}

walker:priv ClearShoppingList {
    has removed_any: bool = False;

    can start with Root entry {
        visit [-->];
    }

    can clear with MealIngredient entry {
        self.removed_any = True;
        del here;
    }

    can done with Root exit {
        report {"cleared": self.removed_any};
    }
}
