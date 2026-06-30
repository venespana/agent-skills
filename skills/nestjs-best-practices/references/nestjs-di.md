# NestJS Dependency Injection

DI patterns, custom providers, and scope management. Based on official NestJS docs.

---

## 1. Constructor Injection (Always Preferred)

Inject dependencies via constructor. NestJS resolves them automatically.

```typescript
@Injectable()
export class UsersService {
  // GOOD — constructor injection, types resolved by NestJS
  constructor(
    private readonly usersRepo: UsersRepository,
    private readonly logger: LoggerService,
  ) {}

  async findById(id: string): Promise<User> {
    this.logger.debug(`Finding user ${id}`);
    return this.usersRepo.findOne(id);
  }
}
```

**Property-based injection** (`@Inject()`) exists but avoid it — it makes testing harder and hides dependencies.

---

## 2. Custom Providers

### useClass (default)
Use when you want NestJS to instantiate the class.

```typescript
@Module({
  providers: [
    { provide: 'I_USER_REPO', useClass: PostgresUserRepository },
  ],
})
export class UsersModule {}
```

### useValue (for constants, mocks, external objects)
Use when you have a pre-built instance or configuration object.

```typescript
const configProvider = {
  provide: 'CONFIG',
  useValue: {
    maxRetries: 3,
    timeoutMs: 5000,
  },
};
```

### useFactory (for dynamic, async dependencies)
Use when creation requires async work or depends on other providers.

```typescript
{
  provide: 'REDIS_CLIENT',
  useFactory: async (configService: ConfigService) => {
    const client = createClient({
      url: configService.get('REDIS_URL'),
    });
    await client.connect();
    return client;
  },
  inject: [ConfigService],
}
```

---

## 3. Injection Tokens

Use interfaces or abstract classes as tokens to enable DIP (Dependency Inversion).

```typescript
// Token: abstract class or interface
export abstract class IUserRepository {
  abstract findById(id: string): Promise<User>;
  abstract save(user: User): Promise<void>;
}

// Implementation
@Injectable()
export class PostgresUserRepository implements IUserRepository {
  async findById(id: string): Promise<User> { /* ... */ }
  async save(user: User): Promise<void> { /* ... */ }
}

// Registration
@Module({
  providers: [
    { provide: IUserRepository, useClass: PostgresUserRepository },
  ],
})
export class UsersModule {}

// Usage — depends on abstraction, not concretion
@Injectable()
export class UsersService {
  constructor(
    private readonly repo: IUserRepository,
  ) {}
}
```

**This is how you apply DIP in NestJS.** The service depends on the interface, not the implementation. Swap `PostgresUserRepository` for `InMemoryUserRepository` in tests without touching the service.

---

## 4. Provider Scopes

### DEFAULT scope (recommended)
Singleton per module. One instance shared across the entire application.

```typescript
@Injectable()
export class UsersService {} // DEFAULT scope by default — best performance
```

### REQUEST scope
New instance per HTTP request. **Avoid unless absolutely necessary** — it has a performance cost because the DI container must instantiate the entire injection chain per request.

```typescript
@Injectable({ scope: Scope.REQUEST })
export class RequestContextService {
  // Each request gets a fresh instance
  // WARNING: all dependents also become request-scoped (cascade)
}
```

### TRANSIENT scope
New instance per injection point. Useful for stateful utilities.

```typescript
@Injectable({ scope: Scope.TRANSIENT })
export class IdGenerator {
  private counter = 0;
  // Each service that injects this gets its own instance
}
```

### Rules:
- **Default to DEFAULT scope.** It gives the best performance.
- REQUEST scope cascades: if a REQUEST-scoped service is injected into another service, that service also becomes REQUEST-scoped.
- TRANSIENT scope does not cascade.
- Never use REQUEST scope for stateless services.

---

## 5. ModuleRef — Dynamic Resolution

Use `ModuleRef` to resolve providers dynamically at runtime (plugins, strategy selection).

```typescript
@Injectable()
export class PaymentProcessorService implements OnModuleInit {
  private strategies: Map<string, IPaymentStrategy>;

  constructor(private moduleRef: ModuleRef) {}

  async onModuleInit() {
    // Register all strategy implementations
    this.strategies = new Map([
      ['stripe', await this.moduleRef.resolve(StripeStrategy)],
      ['paypal', await this.moduleRef.resolve(PaypalStrategy)],
    ]);
  }

  process(payment: PaymentRequest) {
    const strategy = this.strategies.get(payment.method);
    if (!strategy) throw new UnsupportedPaymentMethodError(payment.method);
    return strategy.charge(payment);
  }
}
```

**Use `resolve()` for scoped providers, `get()` for DEFAULT scope.**

---

## 6. Testing with DI

NestJS's DI makes unit testing trivial — inject mocks/fakes via the testing module.

```typescript
describe('UsersService', () => {
  let service: UsersService;
  let repo: jest.Mocked<IUserRepository>;

  beforeEach(async () => {
    const module = await Test.createTestingModule({
      providers: [
        UsersService,
        { provide: IUserRepository, useValue: { findById: jest.fn() } },
      ],
    }).compile();

    service = module.get(UsersService);
    repo = module.get(IUserRepository);
  });

  it('returns user by id', async () => {
    repo.findById.mockResolvedValue({ id: '1', name: 'John' });
    const user = await service.findById('1');
    expect(user.name).toBe('John');
  });
});
```

**Key:** depend on tokens/interfaces so mocks are trivial to inject.

---

## Decision Table

| Situation | Pattern |
|---|---|
| Need to swap implementations (test vs prod) | Token + `useClass` |
| Pre-built instance or config object | `useValue` |
| Async initialization (DB connect, API key fetch) | `useFactory` + `inject` |
| Stateful utility (ID generator) | TRANSIENT scope |
| Request context per HTTP request | REQUEST scope (sparingly) |
| Dynamic strategy selection at runtime | `ModuleRef.resolve()` |
| Property injection `@Inject()` | Avoid — use constructor |
