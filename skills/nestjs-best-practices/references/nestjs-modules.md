# NestJS Module Architecture

Module organization patterns for scalable NestJS applications. Based on official docs and community best practices (2025-2026).

---

## 1. Feature Modules by Bounded Context

**Organize modules by domain area, not by technical layer.** Each feature module encapsulates its controllers, services, repositories, DTOs, and entities.

**BAD — layered structure (anti-pattern):**

```
src/
├── controllers/
│   ├── user.controller.ts
│   ├── order.controller.ts
│   └── product.controller.ts
├── services/
│   ├── user.service.ts
│   ├── order.service.ts
│   └── product.service.ts
└── repositories/
    ├── user.repository.ts
    └── order.repository.ts
```

**GOOD — feature-based (bounded context):**

```
src/
├── users/
│   ├── dto/
│   │   └── create-user.dto.ts
│   ├── entities/
│   │   └── user.entity.ts
│   ├── users.controller.ts
│   ├── users.service.ts
│   ├── users.repository.ts
│   └── users.module.ts
├── orders/
│   ├── dto/
│   ├── entities/
│   ├── orders.controller.ts
│   ├── orders.service.ts
│   ├── orders.module.ts
│   └── orders.module.ts
└── app.module.ts
```

**Rules:**
- One module per domain area.
- Cross-module access goes through the module's `exports`.
- Never import internal services from another module's folder directly.

---

## 2. Module Exports — Public API

Each module exports only what other modules need. Internal helpers stay private.

```typescript
// GOOD — exports only the service, keeps repository private
@Module({
  controllers: [UsersController],
  providers: [UsersService, UsersRepository],
  exports: [UsersService],
})
export class UsersModule {}
```

**Anti-pattern:** exporting everything (`exports: [UsersService, UsersRepository, UserHelper]`). This breaks encapsulation — external modules can bypass the service and hit the repository directly.

---

## 3. Shared Modules

Create a `SharedModule` for truly cross-cutting concerns used by multiple feature modules.

```typescript
@Module({
  providers: [ConfigService, LoggerService, DateUtil],
  exports: [ConfigService, LoggerService, DateUtil],
})
export class SharedModule {}
```

Import `SharedModule` into feature modules that need these services.

**When NOT to use a shared module:**
- Only one feature uses the service → keep it local.
- The service is configuration → use `@Global()` ConfigModule instead.
- The service is infrastructure (DB, cache) → use `@Global()` dynamic module.

---

## 4. Global Modules

Use `@Global()` for modules that must be available everywhere without explicit imports (config, logging, cache).

```typescript
@Global()
@Module({
  providers: [ConfigService],
  exports: [ConfigService],
})
export class ConfigModule {}
```

**Rules:**
- Limit global modules to truly cross-cutting concerns.
- Never make a feature module global — it defeats bounded contexts.
- Prefer explicit imports over global modules when in doubt.

---

## 5. Dynamic Modules

Use dynamic modules when configuration must be provided at runtime (database connections, API keys).

```typescript
// Database module with async configuration
@Module({})
export class DatabaseModule {
  static forRootAsync(options: AsyncConfiguration): DynamicModule {
    return {
      module: DatabaseModule,
      providers: [
        {
          provide: 'DB_CONNECTION',
          useFactory: options.useFactory,
          inject: options.inject,
        },
      ],
    };
  }
}

// Usage in AppModule
@Module({
  imports: [
    DatabaseModule.forRootAsync({
      useFactory: (config: ConfigService) => ({
        host: config.get('DB_HOST'),
        port: config.get('DB_PORT'),
      }),
      inject: [ConfigService],
    }),
  ],
})
export class AppModule {}
```

**Pattern:** `forRoot()` for global configuration, `forFeature()` for feature-specific registration. This is how TypeORM, Mongoose, and other integrations work.

---

## 6. Circular Dependencies

Circular dependencies between modules are a design smell. Resolve by:

1. **Extract shared logic** into a third module both depend on.
2. **Use `forwardRef()`** as a last resort.

```typescript
// Last resort only — signals a design problem
@Module({
  imports: [forwardRef(() => OrdersModule)],
})
export class UsersModule {}
```

**Prefer restructuring over `forwardRef()`.** If Users and Orders need each other, extract the shared concern (e.g., `BillingModule`) that both can depend on.

---

## 7. Lazy Loading

For large applications, lazy-load modules to reduce startup time.

```typescript
// NestJS 9+ supports lazy modules
@Module({})
export class ReportsModule {}

// Loaded on demand
const reportsModule = await import('./reports/reports.module');
```

Use lazy loading for:
- Admin panels rarely accessed
- Heavy reporting modules
- Feature flags that gate entire modules

Do NOT use for:
- Auth modules (needed at startup)
- Core domain modules
- Modules on the critical request path

---

## Decision Table

| Situation | Pattern |
|---|---|
| New domain area | Feature module with its own folder |
| Service used by 3+ modules | SharedModule or `@Global()` |
| Runtime config (DB, API keys) | Dynamic module `forRootAsync()` |
| Two modules need each other | Extract shared third module |
| Heavy module rarely used | Lazy loading |
| Config needed everywhere | `@Global()` ConfigModule |
| Exporting internal helpers | Stop — keep them private |
