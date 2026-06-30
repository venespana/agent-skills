# GDScript / Godot Specific Base

Stack-specific conventions for **GDScript** (Godot 4.x). Load alongside `common-principles.md`.

GDScript is dynamically typed by default but supports **optional static typing**. The community consensus and the official docs agree: **always use static typing or never**. Mixing is the most common pitfall.

---

## 1. Static Typing

- Enable type inference warnings in Project Settings → `debug/gdscript/warnings/`.
- Annotate ALL public function signatures: parameters, return types.
- Annotate member variables: `var health: int = 100`, `@export var speed: float = 5.0`.
- Annotate local variables when the type is not obvious: `var node := get_node("Player") as CharacterBody2D`.
- Mixing `var x = 5` (dynamic) with `var y: int = 5` (static) in the same codebase is forbidden.

**Why**: typed GDScript runs ~30-50% faster (the engine skips reflection), catches errors at parse time, and improves editor autocomplete.

## 2. Naming (Godot Style Guide)

- `snake_case` for variables, functions, files: `player_health`, `take_damage()`, `player.gd`.
- `PascalCase` for classes, nodes, scenes: `Player`, `MainMenu`, `Enemy.tscn`.
- `SCREAMING_SNAKE_CASE` for constants: `MAX_HEALTH`.
- `_camelCase` for private members: `_cached_path`.
- `signal_name_past_tense` for signals: `player_died`, `health_changed`.
- Booleans: `is_alive`, `has_key`, `can_jump`.

## 3. Signals

- Declare with explicit types: `signal health_changed(new_value: int, max_value: int)`.
- Emit with typed args: `health_changed.emit(current, max)`.
- Connect with `connect()` and a Callable — never with string-based connections in Godot 4.
- One signal per event. Don't overload signals with `null` sentinels — split them.

## 4. Scenes & Composition

- One responsibility per scene. A scene is a reusable unit, not a "screen".
- Compose complex objects by instancing scenes, not by deep inheritance.
- Use `@export` for everything configurable from the editor.
- Node references: use `@onready var sprite: Sprite2D = $Sprite2D` (lazy-resolved on `_ready`).

## 5. Autoloads (Singletons)

- Use autoloads **only** for stateless services or truly global state.
- Never use autoload for per-instance data — pass it as a parameter.
- Avoid creating "god autoloads" that import everything and have 20+ methods.

## 6. Lifecycle

- `_ready()` runs once when the node enters the tree. Initialize state here.
- `_process(delta)` runs every frame. Keep it cheap or use `_physics_process(delta)` for physics.
- Never do heavy work in `_process` (no I/O, no allocations if avoidable).
- Use signals + state machines instead of giant if/elif chains in `_process`.

## 7. Functions

- One responsibility per function.
- Prefer pure functions that take inputs and return outputs over methods that mutate self.
- Use `static func` for utility functions that don't need state: `static func damage_amount(base: int, multiplier: float) -> int`.

## 8. Resource Management

- Use `preload("res://path.gd")` for compile-time references.
- Use `load("res://path.gd")` only when the path is dynamic.
- Export `Resource` subclasses (`@export var weapon: WeaponData`) for data-driven design.

## 9. Errors

- Use `push_error("message")` for runtime errors that should not happen.
- Use `assert(condition, "message")` for invariants. Assertions are stripped in release builds.
- Never `print()` for error reporting. Use `push_error` / `push_warning`.