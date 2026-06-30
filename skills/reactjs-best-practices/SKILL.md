---
name: reactjs-best-practices
description: "Trigger: React, ReactJS, JSX, TSX, hooks, components, React 19. Enforce component purity, hooks rules, and SOLID/KISS/DRY in React."
license: Apache-2.0
metadata:
  author: venespana
  version: "1.0"
---

## Activation Contract

Load when writing, reviewing, or refactoring React components (`.jsx`/`.tsx`). Applies to: components, hooks, context, state management, effects.

## Hard Rules

1. **Components and hooks are pure.** Same input → same output. No side effects in the render body.
2. **Props and state are immutable.** Never mutate directly. Use setters / `useState` / `useReducer`.
3. **Hooks rules are non-negotiable.** Top-level only, components/hooks only, no conditionals around hooks.
4. **Effects have cleanup.** Every `useEffect` with a subscription/timer/listener returns a cleanup function.
5. **Stable keys in lists.** No array index as key for dynamic lists. Use stable IDs.
6. **Composition over inheritance.** No class inheritance for components. Compose with props/children.
7. **Comments are WHY only.** No `// renders the button`. Names carry intent.
8. **No magic numbers/strings.** Extract to named constants.
9. **One responsibility per component.** Split if it mixes data fetching + presentation + layout.

## Decision Gates

| Situation | Action |
|---|---|
| Side effect in render body | Move to event handler or `useEffect` |
| Direct state mutation (`state.x = y`) | Use immutable update / setter |
| Conditional hook call | Hoist the hook; use early return after |
| Missing cleanup in effect | Add cleanup for subscriptions/timers |
| Index as key in dynamic list | Replace with stable ID |
| Prop drilling > 2 levels | Consider context or composition |
| Component doing fetch + UI + styling | Split by responsibility (SRP) |

## Execution Steps

1. Read `references/common-principles.md` for SOLID/YAGNI/KISS/DRY + naming/comment rules.
2. Read `references/ts-js-base.md` for shared TS/JS conventions.
3. Apply the hard rules above to every component/hook touched.
4. For refactors: extract custom hooks for logic, split presentation from data fetching.

## Output Contract

Return: files modified, purity issues fixed, hooks violations corrected, effects with cleanup added.

## References

- `references/common-principles.md` — SOLID, YAGNI, KISS, DRY, naming & comment convention.
- `references/ts-js-base.md` — ESM, async/await, error handling, config, logging, TypeScript strictness.
