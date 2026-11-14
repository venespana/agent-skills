---
name: reactjs-best-practices
description: "Trigger: React, ReactJS, JSX, TSX, hooks, components, React 19. Enforce component purity, hooks rules, SOLID/KISS/DRY, and performance optimization in React."
license: Apache-2.0
metadata:
  author: venespana
  version: "1.3"
---

## Activation Contract

Load when writing, reviewing, or refactoring React components (`.jsx`/`.tsx`). Applies to: components, hooks, context, state management, effects, performance optimization.

## Hard Rules

### Correctness
1. **Components and hooks are pure.** Same input → same output. No side effects in render body.
2. **Props and state are immutable.** Never mutate directly.
3. **Hooks rules are non-negotiable.** Top-level only, no conditionals around hooks.
4. **Effects have cleanup.** Every `useEffect` with subscription/timer/listener returns cleanup.
5. **Stable keys in lists.** No array index as key for dynamic lists.
6. **Composition over inheritance.** Compose with props/children.
7. **One responsibility per component.** Split if mixing fetching + presentation + layout.

### Performance (CRITICAL)
8. **Eliminate async waterfalls.** Use `Promise.all` for independent operations. Never `await` sequentially what can run in parallel.
9. **Avoid barrel file imports.** Import from specific files (`library/Module`) not barrel (`library`) to reduce bundle size.
10. **Code-split heavy components.** Use `React.lazy` + `Suspense` for large optional dependencies.
11. **Derive state during render, not in effects.** If state can be computed from props/other state, calculate inline. No `useEffect` to sync.
12. **Functional `setState`.** Use `setState(prev => ...)` when next value depends on previous.
13. **No inline component definitions.** Defining a component inside another remounts it every render.
14. **Passive scroll listeners.** Use `{ passive: true }` on scroll/touch event listeners.

### Code Quality
15. **Comments are WHY only.** Names carry intent.
16. **No magic numbers/strings.** Named constants.
17. **Prefer early return over nested `if`.** Guard clauses first, main logic at base indentation. Max 2 levels of nesting.

### Structure
18. **One component per file.** Each `.jsx`/`.tsx` file exports exactly one component. Non-component helpers go to their own module.
19. **Components are visual-only; behavior lives in hooks.** Business logic, actions, data fetching, and event behavior go into custom hooks (`useXxx`); the component renders and delegates to them. Trivial inline state toggles (e.g. `onClick={() => setOpen(true)}`) are allowed.

## Decision Gates

| Situation | Action |
|---|---|
| Side effect in render body | Move to event handler or `useEffect` |
| Sequential awaits with no dependency | Wrap in `Promise.all` |
| Importing from barrel file | Import from specific module path |
| Heavy component static import | Use `React.lazy` + `Suspense` |
| State synced via `useEffect` | Derive during render or `useMemo` |
| `setState(value + 1)` | Use `setState(prev => prev + 1)` |
| Component defined inside component | Extract to module scope |
| Scroll listener without passive flag | Add `{ passive: true }` |
| Index as key in dynamic list | Replace with stable ID |
| 3+ levels of nested `if` | Flatten with guard clauses (early return) |
| `if` branch returns but `else` still present | Drop the `else` |
| Prop drilling > 2 levels | Consider context or composition |
| 2+ components exported from one file | Split into one file per component |
| Non-trivial handler/business logic inline in component | Extract to a custom hook (`useXxx`) and delegate |

## Execution Steps

1. Apply hard rules and Decision Gates to every component/hook touched.
2. Load references on demand, matched to the task's symptom — never preload all of them:
   - Sequential awaits / waterfalls → `references/react-perf-async.md`
   - Barrel imports / bundle size / code splitting → `references/react-perf-bundle.md`
   - Unnecessary re-renders / memoization / derived state → `references/react-perf-rerender-1.md` (part 2 only if needed)
   - Large lists / rendering cost → `references/react-perf-rendering-1.md` (part 2 only if needed)
   - JS hot paths / micro-optimizations → `references/react-perf-js-1.md` (part 2 only if needed)
   - Client data fetching / advanced patterns → `references/react-perf-client.md`
   - Naming / SOLID / comment rules → `references/common-principles.md`
   - TS strictness / ESM / error-handling conventions → `references/ts-js-base.md`
3. Creating or restructuring a component → follow `references/component-hook-template.md`.
4. For performance work: check waterfalls, barrel imports, unnecessary re-renders, and missing code-splitting before optimizing.

## Output Contract

Return: files modified, correctness issues fixed, performance anti-patterns removed, and any SRP splits made.

## References

- `references/common-principles.md` — SOLID, YAGNI, KISS, DRY, naming & comment convention.
- `references/ts-js-base.md` — ESM, async/await, error handling, config, logging, TypeScript strictness.
- `references/component-hook-template.md` — canonical visual-only component + `useXxx` hook skeleton (Structure rules 18–19).
- `references/react-perf-*.md` — 9 performance reference files (55+ rules adapted from Vercel, Next.js excluded). Load the relevant category for the task at hand.
