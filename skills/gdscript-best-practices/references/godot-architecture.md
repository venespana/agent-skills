# Godot Architecture

Godot-specific architecture patterns: scene composition, node hierarchy, autoload boundaries, and actor decomposition. Based on official Godot best practices docs (sources 1–5).

---

## 1. Godot's Object Model: Scripts as Classes

A script attached to a node extends a built-in engine class. The scene + script pair is the Godot equivalent of a class in OOP. Understanding this is the foundation for everything else.

**Why**: Godot's `ClassDB` provides runtime access to properties, methods, constants, and signals. Attaching a script extends this registry. Scenes are reusable, instantiable, and inheritable groups of nodes — think of them as class instances you can edit in the inspector.

```gdscript
# player.gd — a script that extends CharacterBody2D
class_name Player
extends CharacterBody2D

@export var speed: float = 300.0
var health: int = 100

func _ready() -> void:
    pass  # Initialization when node enters the tree
```

**Anti-pattern**: Using a script without `class_name` and relying on file-path lookups everywhere. Name your types explicitly.

---

## 2. Scene Composition Over Inheritance

Godot scenes are composed, not inherited. Deep inheritance trees are an anti-pattern. Instead, compose scenes by instancing sub-scenes and wiring them via signals or dependency injection.

**GOOD — composition via scene instancing:**

```
World (scene)
├── Player (instanced scene)
├── Enemies (instanced scene)
└── UI (instanced scene)
```

```gdscript
# game_world.gd
extends Node2D

@onready var player_scene: PackedScene = preload("res://actors/player/player.tscn")

func _ready() -> void:
    var player = player_scene.instantiate()
    add_child(player)
    player.health_changed.connect(_on_player_health_changed)
```

**Why**: Scenes that own their dependencies are loosely coupled. You can move a sub-scene anywhere and it will initialize without breaking. This is the key to reusability.

**BAD — god scene with no boundaries:**

```gdscript
# one_scene_handles_everything.gd
# Anti-pattern: one scene doing audio + persistence + UI + domain
func take_damage(amount: int) -> void:
    health -= amount
    save_to_disk()     # persistence concern
    play_sound()       # audio concern
    update_ui()        # UI concern
```

---

## 3. Node Hierarchy and Naming

Name nodes with `PascalCase`. Keep the tree shallow. A node should only be a child of another node if removing the parent would also make the child meaningless.

**Rules for node relationships:**
1. **Is the child meaningful without the parent?** If no → it belongs in the parent's subtree.
2. **Does the child share the parent's lifecycle?** If yes → child of parent.
3. **Does the child need to exist independently across scenes?** If no → sibling or child.

```gdscript
# Node tree for a platformer
Main (main.gd)
├── World (game_world.gd)
│   ├── Platforms (Node2D)
│   ├── Player (instanced player.tscn)
│   └── Enemies (Node2D)
└── GUI (gui.gd)
    ├── HUD (hud.gd)
    └── PauseMenu (pause_menu.gd)
```

**Anti-pattern**: Flattening everything under one "Game" node OR creating 10+ levels of nesting. Keep it logical, not spatial.

---

## 4. Dependency Injection in Scenes

When a scene needs external data, inject it rather than having it hard-code a path or search the tree. Five patterns, from safest to least safe:

**Pattern 1 — Signal connection (safest):**
```gdscript
# Parent connects to child's signal; child emits, parent reacts
# Child has no knowledge of parent
signal health_depleted

func _on_health_changed(value: int) -> void:
    if value <= 0:
        health_depleted.emit()
```

**Pattern 2 — Callable property:**
```gdscript
# Parent assigns a callback to the child
# Child calls it without knowing who set it up
@export var on_damage_taken: Callable

func take_damage(amount: int) -> void:
    on_damage_taken.call(amount)
```

**Pattern 3 — Node reference:**
```gdscript
# Child holds a reference injected by parent
@export var target: Node

func apply_effect() -> void:
    if target and target.has_method("apply_damage_modifier"):
        target.apply_damage_modifier(1.5)
```

**Pattern 4 — NodePath:**
```gdscript
# Parent sets a path; child resolves it at runtime
@export var target_path: NodePath

func _ready() -> void:
    target = get_node(target_path)
```

**Pattern 5 — Autoload (use sparingly):**
```gdscript
# Only for true singletons managing their own data
func use_global() -> void:
    var config = GlobalConfig.get_singleton()
    print(config.get_setting("player_speed"))
```

**Why**: Loose coupling. A scene that knows nothing about its environment can be reused in any context.

---

## 5. Autoloads: When to Use Them (and When Not To)

Autoloads load as children of root, persisting across scene changes. They are **not** inherently singletons — you can instance copies. But the pattern implies global access.

**GOOD uses for autoloads:**
- Global configuration (`GameSettings`, `GlobalConfig`)
- Audio management with a pool (`SoundManager` — pools `AudioStreamPlayer` nodes)
- Dialogue/quest systems that manage their own state across scenes
- Input manager for complex input handling

**BAD uses for autoloads:**
- Per-instance player state (`current_player_health`, `player_position`)
- Scene-specific data that should live in the scene tree
- "God autoloads" that accumulate 20+ methods doing unrelated things

```gdscript
# BAD — autoload holding per-instance state
# PlayerManager.gd (autoload)
var current_player: Player       # per-instance data — NO
var player_health: int = 100     # per-instance data — NO
var player_position: Vector2      # per-instance data — NO

# GOOD — stateless service
# AudioManager.gd (autoload)
func play_sound(sound_path: String, volume_db: float = 0.0) -> void:
    # pools AudioStreamPlayer nodes, manages its own state
    pass
```

**Rule of thumb**: If the autoload would have `set_player(player)` or tracks individual object state, it belongs in the scene tree.

**Since Godot 4.1**: Use `static var` and `static func` in a `class_name` script instead of an autoload for shared data/utility functions. Autoloads are still useful for systems that need to persist across scene changes.

---

## 6. The "Actor" Decomposition Pattern

Split god-class scripts into three concerns:
1. **Domain** — health, inventory, stats (the "what it is")
2. **Persistence** — save/load (the "how to persist")
3. **Presentation** — UI updates, audio feedback (the "how it looks")

```gdscript
# player_domain.gd — domain only
class_name PlayerDomain
extends CharacterBody2D

signal health_changed(new_value: int, max_value: int)
signal died

@export var max_health: int = 100
var current_health: int = max_health

func take_damage(amount: int) -> void:
    current_health = max(0, current_health - amount)
    health_changed.emit(current_health, max_health)
    if current_health == 0:
        died.emit()
```

```gdscript
# player_persistence.gd — listens to domain, saves
func _ready() -> void:
    domain.health_changed.connect(_on_health_changed)
    domain.died.connect(_on_died)

func _on_health_changed(new_value: int, max_value: int) -> void:
    save_game()

func _on_died() -> void:
    save_game()  # record death
```

```gdscript
# player_ui.gd — listens to domain, updates UI
func _ready() -> void:
    domain.health_changed.connect(_update_health_bar)

func _update_health_bar(new_value: int, max_value: int) -> void:
    $HealthBar.max_value = max_value
    $HealthBar.value = new_value
```

**Why**: Each concern changes for a different reason (game designer, backend dev, UI designer). One actor per script = one reason to change.

---

## 7. Scenes vs Scripts: When to Use Which

| Use a **Script** | Use a **Scene** |
|---|---|
| Reusable tool/utility type | Game-specific concept |
| Editor integration needed (`@tool`) | Node hierarchy required |
| Lightweight data/logic | Complex initialization of many nodes |
| Class-like API with `class_name` | State + structure + behavior |
| One-off behavior | Reusable unit instanced multiple times |

```gdscript
# Script as a named type (tool script for editor)
@tool
class_name MyEditorTool
extends EditorScript

func _run() -> void:
    # Runs in editor context
    pass
```

```gdscript
# Scene for in-game objects
# enemy.tscn — PackedScene, instantiated at runtime
const EnemyScene = preload("res://enemies/enemy.tscn")

func spawn_enemy(position: Vector2) -> void:
    var enemy = EnemyScene.instantiate()
    enemy.position = position
    add_child(enemy)
```

**Performance note**: `PackedScene.instantiate()` is faster than creating nodes imperatively with `.new()` + `add_child()`. The engine handles scene instantiation in optimized C++ batches.

---

## 8. Scene Isolation and Reusability

A well-designed scene:
- Has no hard-coded paths to sibling/parent scenes
- Receives dependencies via signals, Callable properties, or exported references
- Implements `_get_configuration_warnings()` to self-document required setup

```gdscript
# weapon.gd — scene that needs external configuration
class_name Weapon
extends Node2D

@export var damage_multiplier: float = 1.0
var owner: Node  # Injected by the parent scene

func _get_configuration_warnings() -> PackedStringArray:
    if owner == null:
        return ["'owner' must be set by the parent scene"]
    return []
```

**Why**: Scenes that self-document via `_get_configuration_warnings()` prevent silent misconfiguration. The editor shows a warning icon with your message.

---

## 9. Project Entry Point Structure

Every game needs an entry point. A `Main` node at root drives scene switching.

```gdscript
# main.gd
extends Node

@onready var world_container: Node2D = $WorldContainer
@onready var gui_layer: CanvasLayer = $GUI

func _ready() -> void:
    load_world_scene("res://levels/level_1.tscn")

func load_world_scene(scene_path: String) -> void:
    # Clear old world
    for child in world_container.get_children():
        child.queue_free()
    # Load new world
    var world_scene = load(scene_path) as PackedScene
    var world = world_scene.instantiate()
    world_container.add_child(world)
```

**Why**: Separating world container from UI (GUI on `CanvasLayer`) means scene transitions don't destroy the HUD.

---

## Anti-Patterns

- **God scene**: One script/node doing domain + persistence + UI + audio. Split by actor.
- **Hard-coded paths**: `get_node("/root/Main/World/Player")` everywhere. Use signals or exported refs.
- **Autoload for per-instance state**: `PlayerManager.current_health` is a red flag. Pass as parameter.
- **Deep inheritance**: `Character → MobileCharacter → Player → FlyingPlayer`. Use composition instead.
- **Scene as utility**: Creating a scene just to hold a math utility function. Use a `class_name` script with `static func`.
- **Tight coupling via direct node access**: Sibling A accessing `$SiblingB` directly. Use parent-mediated signals.
