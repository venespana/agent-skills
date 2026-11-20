# F1 — Evidence package (validation-flow skill)

Work unit: T1 + T2 + T3 + T4 + T5 + T8 (T6 pending approval, T7 pending user
decision). Date: 2026-11-20. Format per the doctrine itself: Diff / Checks /
Risk / Evidence.

## Diff

| File | Action | Lines |
|------|--------|-------|
| `skills/validation-flow/SKILL.md` | New | 89 (v1.1, skill-improver audit applied) |
| `skills/validation-flow/commands/evidencia.md` | New | 34 |
| `README.md` | Modified (Available Skills table) | 21 total |
| `.gitignore` | Modified by `gentle-ai skill-registry refresh` (tool side-effect: ignores `.atl/` entirely — matches the standing practice of not pushing `.atl` to remote) | +2 |
| `odd/tasks/f1-validation-flow-skill.md` | New (ODD) | 53 |
| `odd/artifacts/f1/*` | New (this package) | — |

Raw status: see `checks.log`, section "work-unit diff".

## Checks — all GREEN

| Check | Result | Proof |
|-------|--------|-------|
| T3 independence grep (project/framework/home-path markers) | 0 hits (`grep exit=1`) | `checks.log` § T3 |
| T3b sanctioned platform mentions | only the 2 S8 install targets, `~`-paths | `checks.log` § T3b |
| T4 SKILL.md frontmatter structural | delimiters + all required keys | `checks.log` § T4 |
| T4c SKILL.md frontmatter YAML parse | OK — `validation-flow v1.0` (python3 + pyyaml) | `checks.log` § T4c |
| T4b command frontmatter + no-commit marker | frontmatter OK; "Do not commit" line 34 | `checks.log` § T4b + T4b-fix |
| T4b-fix command shell block (`!` + git) | present, raw excerpt in log | `checks.log` § T4b-fix |

`N/A — <reason>` notes per S12:

- **Screenshots**: N/A — markdown-only change, no UI surface exists in this
  repository.
- **Application logs**: N/A — no runtime was exercised; the change ships
  files, it does not execute an app.

## Risk

None — no tier-B/C surface touched: no security surfaces, no real external
effects, no destructive operations, no consumer repository modified.

## Evidence (artifact paths)

- `odd/artifacts/f1/architecture.md` — diagram of the three-piece
  architecture + the delivery-ritual sequence (mermaid).
- `odd/artifacts/f1/checks.log` — raw output of every check, timestamped.
- `odd/tasks/f1-validation-flow-skill.md` — the ODD governing this unit.
