---
name: nestjs-best-practices
description: "Trigger: NestJS, Nest, @Module, @Controller, @Injectable, DTO, guards, interceptors. Enforce layered architecture, DI, and SOLID/KISS/DRY in NestJS."
license: Apache-2.0
metadata:
  author: venespana
  version: "1.0"
---

## Activation Contract

Load when writing, reviewing, or refactoring NestJS code (modules, controllers, services, providers). Applies to: controllers, services, DTOs, guards, pipes, interceptors, modules.

## Hard Rules

1. **Controllers are thin.** Only parse request, call service, return response. No business logic.
2. **Services hold domain logic.** Marked `@Injectable()`. One responsibility per service.
3. **DTOs validate input.** Every endpoint has a DTO with `class-validator` decorators. Enable `ValidationPipe` globally.
4. **Dependency injection over `new`.** Inject services via constructor. Never `new Service()` inside another service.
5. **Modules by bounded context.** `src/orders/` not `src/controllers/`. One module per domain area.
6. **Guards for auth, interceptors for cross-cutting concerns.** Do not mix auth logic into controllers.
7. **Comments are WHY only.** No narrative. Names carry intent.
8. **No magic numbers.** Named constants.
9. **Errors via exception filters.** Throw domain exceptions; let filters handle HTTP mapping.
10. **Prefer early return over nested `if`.** Guard clauses first, main logic at base indentation. Max 2 levels of nesting.

## Decision Gates

| Situation | Action |
|---|---|
| Business logic in controller | Move to service |
| `new SomeService()` inside a class | Inject via constructor |
| Endpoint without DTO | Add DTO + validation decorators |
| Module importing everything | Split by bounded context |
| Auth check inside controller | Extract to a Guard |
| Logging scattered in services | Extract to a global interceptor |
| Service doing validation + persistence + notification | Split by SRP |
| 3+ levels of nested `if` | Flatten with guard clauses (early return) |
| `if` branch returns but `else` still present | Drop the `else` |

## Execution Steps

1. Read `references/common-principles.md` for SOLID/YAGNI/KISS/DRY + naming/comment rules.
2. Read `references/ts-js-base.md` for shared TS/JS conventions.
3. Apply the hard rules above to every NestJS file touched.
4. For refactors: thin controllers, fat services, validated DTOs, injected dependencies.

## Output Contract

Return: files modified, architecture violations fixed, DI issues corrected, missing DTOs added.

## References

- `references/common-principles.md` — SOLID, YAGNI, KISS, DRY, naming & comment convention.
- `references/ts-js-base.md` — ESM, async/await, error handling, config, logging, TypeScript strictness.
