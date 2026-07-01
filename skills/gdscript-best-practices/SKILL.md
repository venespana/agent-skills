---
name: gdscript-best-practices
description: "Trigger: GDScript, Godot, .gd files, Godot 4 scripting. Enforce clean code, static typing, SOLID/KISS/DRY, architecture, and performance in GDScript."
license: Apache-2.0
metadata:
  author: venespana
  version: "1.1"
---

## Activation Contract

Load when writing, reviewing, or refactoring GDScript (`.gd`) files in Godot 4.x projects.

## Hard Rules

### Typing
1. **Static typing: all or nothing.** Never mix `var x = 5` with `var y: int = 5`. Annotate all signatures, parameters, return types, members.
2. **Typed signals.** `signal health_changed(new_value: int, max: int)`. Emit via `.emit()`, never string-based.

### Naming
3. **Godot style.** `snake_case` vars/funcs/files, `PascalCase` classes/nodes, `_underscore` private, past tense signals.

### Code Quality
4. **Comments are WHY only.** Names carry intent.
5. **No magic numbers.** `const MAX_HEALTH := 100`.
6. **Early return.** Max 2 levels nesting. Drop `else` after returning `if`.
7. **One responsibility per function.** ≤20 lines. Extract when exceeded.

### Architecture
8. **Scene composition over inheritance.** Split god classes by actor (domain/persistence/UI/audio).
9. **Autoloads are stateless services.** Never per-instance state.
10. **Inject dependencies.** Signals, Callable props, or `@export`. No hard-coded paths.
11. **Resources for data, Nodes for behavior.** Data-only → Resource/RefCounted.
12. **Consider alternatives for mass nodes.** Object/RefCounted over Node for 1000s of items.

### Performance
13. **`_process` stays cheap.** Signals, state machines, `Timer` for heavy work.
14. **`_physics_process` for physics. `_process` for visuals. `_unhandled_input` for input.**
15. **Cache node refs in hot paths.** `@onready` — never `get_node()` in `_process`.
16. **`queue_free()` over `free()`.** Immediate free orphans children.
17. **Pool frequently spawned entities.**

### Lifecycle
18. **Connect in `_enter_tree`, disconnect in `_exit_tree`.** Or `CONNECT_ONE_SHOT`.
19. **`NOTIFICATION_PARENTED`** fires when added to any parent — use for self-configuring nodes.

## Decision Gates

| Situation | Action |
|---|---|
| Mixed typing | Pick one (typed) |
| God class (save+UI+audio) | Split by actor |
| Autoload growing | Decompose |
| Per-instance state in autoload | Move to scene tree |
| `get_node()` in `_process` | `@onready` cache |
| `free()` in callback | `queue_free()` |
| Node for data | `Resource`/RefCounted |
| if/elif chain | State machine |
| 3+ nested `if` | Guard clauses |
| Speculative method | YAGNI |

## Execution Steps

1. Read `references/common-principles.md` + `references/gdscript-base.md`.
2. Read architecture/design/performance refs as needed for the task.
3. Apply hard rules. For refactors: split by actor, wire via signals.
4. Profile before optimizing.

## Output Contract

Return: files modified, principles applied, anti-patterns removed.

## References

- `references/common-principles.md` — SOLID, YAGNI, KISS, DRY, naming.
- `references/gdscript-base.md` — typing, signals, scenes, lifecycle.
- `references/godot-architecture.md` — scene composition, autoloads.
- `references/godot-design-patterns.md` — node alternatives, notifications, state machines.
- `references/godot-project.md` — project structure, VCS.
- `references/gdscript-performance.md` — typed GDScript, pooling, profiling.
