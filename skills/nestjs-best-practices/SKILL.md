---
name: nestjs-best-practices
description: "Trigger: NestJS, Nest, @Module, @Controller, @Injectable, DTO, guards, interceptors. Enforce layered architecture, DI, validation, and SOLID/KISS/DRY in NestJS."
license: Apache-2.0
metadata:
  author: venespana
  version: "1.1"
---

## Activation Contract

Load when writing, reviewing, or refactoring NestJS code. Applies to: modules, controllers, services, providers, DTOs, guards, pipes, interceptors, filters, architecture.

## Hard Rules

### Architecture
1. **Controllers are thin.** Parse request, call service, return response. No business logic.
2. **Services hold domain logic.** Marked `@Injectable()`. One responsibility per service.
3. **Modules by bounded context.** `src/orders/` not `src/controllers/`. One module per domain area.
4. **Modules export only their public API.** Internal helpers stay private. Never export repositories — export the service.

### Dependency Injection
5. **DI over `new`.** Inject via constructor. Never `new Service()` inside another service.
6. **Depend on abstractions (tokens/interfaces).** Use `provide: IUserRepository, useClass: ...` so implementations are swappable.
7. **Default scope (singleton).** Avoid REQUEST scope — it cascades and hurts performance.

### Validation
8. **DTOs on every endpoint.** Every input has a DTO with `class-validator` decorators. `ValidationPipe` global with `whitelist: true` + `forbidNonWhitelisted: true`.
9. **Route params validated.** Use `ParseUUIDPipe`, `ParseIntPipe`, or custom pipes on all `@Param` and `@Query`.
10. **Response DTOs.** Never return raw entities. Use `@Expose()` / `@Exclude()` to control output.

### Cross-Cutting
11. **Guards for auth.** RBAC via `@Roles()` decorator + `RolesGuard`. Register global guards via `APP_GUARD`.
12. **Interceptors for logging/caching/timeout.** Register via `APP_INTERCEPTOR`. Not in controllers.
13. **Exception filters for error mapping.** Throw domain exceptions (`UserNotFoundException`). Let filters map to HTTP.
14. **Prefer `APP_*` tokens over `useGlobal*()`.** Token registration enables DI.

### Code Quality
15. **Comments are WHY only.** Names carry intent.
16. **No magic numbers.** Named constants.
17. **Prefer early return over nested `if`.** Guard clauses first, max 2 levels of nesting.

## Decision Gates

| Situation | Action |
|---|---|
| Business logic in controller | Move to service |
| `new SomeService()` inside a class | Inject via constructor |
| Hardcoded dependency (PostgresRepo) | Extract interface, use token provider |
| Endpoint without DTO | Add DTO + validation decorators |
| Unknown properties in payload | `whitelist: true` + `forbidNonWhitelisted: true` |
| Module importing everything | Split by bounded context |
| Auth check inside controller | Extract to a Guard + `@Roles()` |
| Logging scattered in services | Global interceptor via `APP_INTERCEPTOR` |
| Raw entity returned to client | Response DTO + `@Exclude()` sensitive fields |
| REQUEST-scoped service | DEFAULT scope unless truly per-request state |
| Service doing validation + persistence + notification | Split by SRP |
| 3+ levels of nested `if` | Flatten with guard clauses |
| Complex domain with multiple contexts | Hexagonal: ports + adapters (see architecture ref) |

## Execution Steps

1. Read `references/common-principles.md` for SOLID/YAGNI/KISS/DRY + naming/comment rules.
2. Read `references/ts-js-base.md` for shared TS/JS conventions.
3. Read the NestJS-specific references for the task at hand:
   - `references/nestjs-modules.md` — module organization, bounded contexts, exports
   - `references/nestjs-di.md` — providers, scopes, tokens, testing
   - `references/nestjs-pipeline.md` — DTOs, validation, pipes, response serialization
   - `references/nestjs-cross-cutting.md` — guards, interceptors, middleware, filters
   - `references/nestjs-architecture.md` — layered, hexagonal, DDD, CQRS
4. Apply the hard rules above to every NestJS file touched.
5. For new endpoints: DTO + ValidationPipe + thin controller + service with injected deps.
6. For architecture decisions: match the complexity level (CRUD → layered; complex → hexagonal).

## Output Contract

Return: files modified, architecture violations fixed, DI issues corrected, missing DTOs/validation added, cross-cutting concerns properly registered.

## References

- `references/common-principles.md` — SOLID, YAGNI, KISS, DRY, naming & comment convention.
- `references/ts-js-base.md` — ESM, async/await, error handling, config, logging, TypeScript strictness.
- `references/nestjs-modules.md` — feature modules, exports, dynamic modules, circular deps.
- `references/nestjs-di.md` — custom providers, scopes, tokens, ModuleRef, testing with DI.
- `references/nestjs-pipeline.md` — DTOs, class-validator, ValidationPipe, nested validation, response serialization.
- `references/nestjs-cross-cutting.md` — guards, interceptors, middleware, exception filters, execution order.
- `references/nestjs-architecture.md` — layered, hexagonal/ports-adapters, domain entities, CQRS decision guide.
