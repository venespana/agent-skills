# Godot Design Patterns

Node alternatives, Godot interfaces (virtual methods), notifications, data preferences, and logic patterns. Based on official Godot best practices docs (sources 6–10).

---

## 1. When NOT to Use a Node

Nodes are cheap but not free. A project with tens of thousands of nodes paying for the full Node API overhead. Godot provides lighter alternatives:

### Object (manual memory)
The ultimate lightweight. Must call `free()` manually. Use for custom data structures.

```gdscript
class_name TreeNode
extends Object

var _parent: TreeNode = null
var _children := []

func _notification(p_what: int) -> void:
    match p_what:
        NOTIFICATION_PREDELETE:
            for child in _children:
                child.free()
```

**Why**: TreeNode doesn't need `Node`'s scene tree integration, signals, or `_process`. It saves memory and CPU for large data structures (thousands of items).

### RefCounted (auto-free)
Auto-frees when no references remain. No manual `free()` needed.

```gdscript
class_name InventorySlot
extends RefCounted

var item_name: String
var quantity: int

func _init(p_item: String = "", p_qty: int = 0) -> void:
    item_name = p_item
    quantity = p_qty
```

**Why**: Same as Object but reference-counted. Safe for cases where you pass references around and don't want to manage deletion.

### Resource (serializable)
Can save/load to disk. Inspector-compatible via `@export`.

```gdscript
class_name WeaponData
extends Resource

@export var name: String = "Fist"
@export var damage: int = 10
@export var range_units: float = 1.5
```

**Why**: Resources serialize natively to `.tres` files. Many identical instances share the same file reference. Perfect for data that belongs in asset files (weapons, items, stats).

**Anti-pattern**: Creating a Node subclass when all you need is data. If it has no behavior needing the scene tree, it should be a Resource.

---

## 2. Godot Interfaces: Virtual Methods and Duck Typing

Godot is duck-typed — if an object has the method, you can call it. No interface declaration needed.

### Checking for method existence

```gdscript
func apply_effect(target: Node) -> void:
    if target.has_method("take_damage"):
        target.take_damage(5)
    if target.has_method("heal"):
        target.heal(3)
```

### Using groups as implicit interfaces

Define project conventions like `"damageable"`, `"quest"`, `"interactable"`:

```gdscript
# Any node in the "quest" group that implements complete() and fail() satisfies this
func _on_player_died() -> void:
    for node in get_tree().get_nodes_in_group("quest"):
        node.fail()
```

**Why**: Group-based "interfaces" are duck-typed and don't require inheritance. Any script that conforms to the documented interface can fill the role.

### Callable for max flexibility

```gdscript
# parent.gd — passes a callable to child
@onready var child = $Child

func _ready() -> void:
    child.action = Callable(self, "do_something")
    child.perform_action()

func do_something() -> void:
    print("Action executed by child, owned by parent")
```

```gdscript
# child.gd
extends Node

var action: Callable

func perform_action() -> void:
    if action.is_valid():
        action.call()
```

**Why**: Callable decouples the method owner from the method name. No need for the child to know about the parent's class.

---

## 3. Godot Notifications

Every `Object` has `_notification()` receiving `NOTIFICATION_*` constants. Dedicated virtual methods exist for the most common ones.

### Lifecycle notifications

| Notification | Virtual method | When it fires |
|---|---|---|
| `NOTIFICATION_READY` | `_ready()` | Node entered tree, children ready |
| `NOTIFICATION_ENTER_TREE` | `_enter_tree()` | About to enter tree |
| `NOTIFICATION_EXIT_TREE` | `_exit_tree()` | About to leave tree |
| `NOTIFICATION_PARENTED` | — | Added as child to any node |
| `NOTIFICATION_UNPARENTED` | — | Removed from any parent |
| `NOTIFICATION_PREDDELETE` | — | Before object is freed |
| `NOTIFICATION_PROCESS` | `_process(delta)` | Every frame |
| `NOTIFICATION_PHYSICS_PROCESS` | `_physics_process(delta)` | Every physics step |
| `NOTIFICATION_DRAW` | `_draw()` | Canvas item should redraw |

### NOTIFICATION_PARENTED for self-configuring nodes

```gdscript
# A node that auto-connects to its parent's signal when added
extends Node

var _parent_cache: Node

func _notification(what: int) -> void:
    match what:
        NOTIFICATION_PARENTED:
            _parent_cache = get_parent()
            if _parent_cache.has_user_signal("interacted_with"):
                _parent_cache.interacted_with.connect(_on_parent_interacted)
        NOTIFICATION_UNPARENTED:
            if _parent_cache and _parent_cache.has_user_signal("interacted_with"):
                _parent_cache.interacted_with.disconnect(_on_parent_interacted)

func _on_parent_interacted() -> void:
    print("Reacting to parent's interaction")
```

**Why**: `NOTIFICATION_PARENTED` fires when a node is added to **any** parent, not just the scene tree. Use it for nodes that need to wire themselves to their context at runtime.

### When to use signals vs notifications

| Use signals | Use `_notification()` |
|---|---|
| Cross-scene communication | Internal lifecycle events |
| One-to-many broadcasts | One-to-one engine callbacks |
| Decoupled, emitter doesn't know receivers | Tightly coupled to engine events |
| Gameplay events (damage, death, pickup) | Engine events (enter tree, draw, parented) |

---

## 4. Data Storage: Arrays, Dictionaries, Objects, Resources

### Array vs Dictionary

**Array** (`Vector<Variant>`):
- Contiguous memory — fast iteration, fast get/set by index
- Slow insert/erase in middle (shifts all elements)
- Fast append/prepend at ends

```gdscript
var items: Array[String] = []
items.append("sword")
items.append("shield")
for item in items:
    print(item)
```

**Dictionary** (`HashMap<Variant, Variant>`):
- Key-value with O(1) get/set
- Maintains insertion order
- Faster insert/erase than Array for scattered access

```gdscript
var stats: Dictionary = {
    "health": 100,
    "mana": 50,
    "strength": 15
}
stats["health"] = 90
```

**Rule**: Use Array for sequential data (inventory list, path points). Use Dictionary for named properties (character stats, config).

### Object/RefCounted for structured data with behavior

```gdscript
class_name CharacterStats
extends RefCounted

var max_health: int
var current_health: int
var attack_power: int
var defense: int

signal health_changed(new_hp: int)
signal died

func take_damage(amount: int) -> void:
    current_health = max(0, current_health - amount)
    health_changed.emit(current_health)
    if current_health == 0:
        died.emit()
```

**Why**: Object gives you methods, signals, and type safety. Dictionary is faster for simple lookups but has no enforcement.

### Resource for persistent/serializable data

```gdscript
# item_data.gd
class_name ItemData
extends Resource

@export var display_name: String
@export var description: String
@export var icon: Texture2D
@export var stack_size: int = 1
@export var max_stack: int = 99
```

```gdscript
# Export in a scene or script
@export var equipped_weapon: ItemData
```

**Why**: Resources serialize to `.tres` files, can be edited in the inspector, and are cached by the engine. Loading the same resource path returns the same in-memory instance.

---

## 5. State Machines

Avoid giant `if/elif` chains in `_process`. Use a state machine.

### Enum-based simple state

```gdscript
enum State { IDLE, RUN, JUMP, FALL }

@export var current_state: State = State.IDLE

func _physics_process(delta: float) -> void:
    match current_state:
        State.IDLE:
            velocity.x = move_toward(velocity.x, 0, friction * delta)
            if input_direction != Vector2.ZERO:
                current_state = State.RUN
        State.RUN:
            velocity.x = move_toward(velocity.x, input_direction.x * max_speed, acceleration * delta)
            if not is_on_floor():
                current_state = State.JUMP
        State.JUMP:
            velocity.y -= gravity * delta
            if velocity.y > 0:
                current_state = State.FALL
        State.FALL:
            velocity.y = min(velocity.y + gravity * delta, max_fall_speed)
            if is_on_floor():
                current_state = State.IDLE
```

### Strategy pattern via exported node/type

```gdscript
# behavior.gd — base behavior class
class_name Behavior
extends Node

func execute(actor: Node, delta: float) -> void:
    pass  # Override in subclasses
```

```gdscript
# aggressive_behavior.gd
class_name AggressiveBehavior
extends Behavior

func execute(actor: Node, delta: float) -> void:
    actor.velocity.x = actor.move_direction * actor.max_speed
```

```gdscript
# passive_behavior.gd
class_name PassiveBehavior
extends Behavior

func execute(actor: Node, delta: float) -> void:
    actor.velocity.x = 0
```

```gdscript
# ai_controller.gd
@export var behavior: Behavior

func _physics_process(delta: float) -> void:
    behavior.execute(self, delta)
```

**Why**: Swap behavior at runtime, in the inspector, or per-instance. No inheritance chain needed.

---

## 6. Initialization Order: `_init` vs `_ready` vs `@export`

Property initialization order (when instantiating a scene):

1. **Declaration default** — `var x = 5` sets initial value, does NOT trigger setter
2. **`_init()`** — runs, setters ARE triggered
3. **Exported value** — Inspector value applied, setters triggered again

```gdscript
@export var test: String = "one":
    set(value):
        test = value + "!"

func _init():
    # Triggers setter → test = "two!"
    test = "two"
# Inspector sets test to "three" → setter → test = "three!"
```

**Rule**: Set node properties before `add_child()`, not after. Many setters trigger expensive logic (e.g., `position` triggers transform updates).

```gdscript
# GOOD — set properties before adding
var enemy = Enemy.new()
enemy.name = "Goblin"
enemy.global_position = spawn_point
add_child(enemy)

# BAD — properties set after entering tree may trigger extra work
var enemy = Enemy.new()
add_child(enemy)  # _enter_tree fires here
enemy.name = "Goblin"  # setter runs in-tree
enemy.global_position = spawn_point  # transform recalculated
```

---

## 7. Enums: int vs String

GDScript supports both. Integer enums are faster (O(1) comparison). String enums print nicely.

```gdscript
# Integer enum — use for performance-critical comparisons
enum Facing { LEFT, RIGHT, UP, DOWN }

# String enum — use for display/debugging
@export_enum("Easy", "Normal", "Hard") var difficulty: int
```

**Rule**: Default to integer enums for comparisons. Use string enums via `@export_enum` when you need the string representation for UI or debugging.

---

## 8. Avoiding Deep Inheritance

Godot's node system naturally encourages composition. If you find yourself writing:

```gdscript
class_name Animal
class_name DomesticAnimal extends Animal
class_name Pet extends DomesticAnimal
class_name Cat extends Pet
class_name PersianCat extends Cat
```

Stop. Use composition + components instead:

```gdscript
# Components attached to a node
@onready var hunger_component: HungerComponent = $HungerComponent
@onready var meow_component: MeowComponent = $MeowComponent
@onready var purr_component: PurrComponent = $PurrComponent
```

**Why**: Cat and Dog share `HungerComponent` but not `MeowComponent`. Inheritance forces shared ancestors. Components are mixed and matched freely.

---

## Anti-Patterns

- **Node for data-only objects**: If it has no scene-tree behavior, use `RefCounted` or `Resource`.
- **String-based signal connections**: `emit_signal("health_changed", value)` instead of `health_changed.emit(value)`.
- **`_process` doing heavy work every frame**: If it doesn't need to run every frame, use a `Timer`.
- **Giant `if/elif` chains**: State machines or `match` statements reduce nesting and improve readability.
- **Hard-coding values in methods**: Use `@export` or `const` — no magic numbers.
- **Initializing nodes after `add_child()`**: Set properties before adding to the tree.
- **`preload()` for dynamic paths**: Use `load()` when the path is only known at runtime.
