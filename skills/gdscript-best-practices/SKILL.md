---
name: gdscript-best-practices
description: "Trigger: GDScript, Godot, .gd files, Godot 4 scripting. Enforce clean code, static typing, and SOLID/KISS/DRY principles in GDScript."
license: Apache-2.0
metadata:
  author: venespana
  version: "1.0"
---

## Activation Contract

Load when writing, reviewing, or refactoring GDScript (`.gd`) files in Godot 4.x projects. Applies to: new scripts, code review, refactoring autoloads/signals/scenes.

## Hard Rules

1. **Static typing: all or nothing.** Never mix `var x = 5` with `var y: int = 5`. Annotate all signatures and members.
2. **Naming follows Godot style:** `snake_case` for vars/funcs/files, `PascalCase` for classes/nodes, `_underscore` for private, past tense for signals (`health_changed`).
3. **Signals are typed:** `signal health_changed(new_value: int, max: int)`. Connect via Callable, never string-based.
4. **Comments are WHY only.** No `# this adds two numbers`. Names carry intent; silence is correct.
5. **No magic numbers.** Extract to `const MAX_HEALTH := 100`.
6. **One responsibility per scene/script.** Split god classes by actor (domain, persistence, UI, audio).
7. **Autoloads are stateless services only.** Never per-instance state.
8. **`_process` stays cheap.** Heavy logic goes to signals + state machines.

## Decision Gates

| Situation | Action |
|---|---|
| Mixing typed and untyped vars | Pick one style project-wide (prefer typed) |
| Class does save + UI + audio | Split by concern; emit signals |
| Autoload growing past 10 methods | It is a god object — decompose |
| Function > 20 lines | Extract; likely violates SRP |
| `# comment` narrating code | Delete it; rename if unclear |
| Speculative method "for flexibility" | YAGNI — remove until a real caller exists |

## Execution Steps

1. Read `references/common-principles.md` for SOLID/YAGNI/KISS/DRY + naming/comment rules.
2. Read `references/gdscript-base.md` for Godot-specific patterns (typing, signals, scenes, lifecycle).
3. Apply the hard rules above to every `.gd` file touched.
4. For refactors: identify actors, split by SRP, use signals for cross-concern communication.
5. Verify no mixing of static/dynamic typing.

## Output Contract

Return: files modified, principles applied, anti-patterns removed, and any SRP splits made.

## References

- `references/common-principles.md` — SOLID, YAGNI, KISS, DRY, naming & comment convention.
- `references/gdscript-base.md` — Godot 4 static typing, signals, scenes, autoloads, lifecycle.
