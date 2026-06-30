# NestJS Clean & Hexagonal Architecture

Architecture patterns for maintainable NestJS applications. Based on industry practices (2025-2026) and NestJS docs.

---

## 1. Layered Architecture (Baseline)

The minimum viable structure: Controller → Service → Repository.

```
Controller (HTTP layer)
    ↓ calls
Service (Business logic)
    ↓ calls
Repository (Data access)
```

**Rules:**
- Controllers parse HTTP, call services, return responses. No business logic.
- Services contain domain logic. They don't know about HTTP.
- Repositories know about the database. They don't contain business logic.
- Dependencies point inward: Controller → Service → Repository. Never reverse.

```typescript
// GOOD — controller is thin
@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Post()
  async create(@Body() dto: CreateUserDto): Promise<UserResponseDto> {
    return this.usersService.create(dto);
  }
}

// GOOD — service has business logic, no HTTP knowledge
@Injectable()
export class UsersService {
  constructor(
    private readonly repo: IUserRepository,
    private readonly emailService: IEmailService,
  ) {}

  async create(dto: CreateUserDto): Promise<UserResponseDto> {
    const existing = await this.repo.findByEmail(dto.email);
    if (existing) throw new EmailAlreadyExistsException(dto.email);

    const user = await this.repo.save(dto);
    await this.emailService.sendWelcome(user.email);
    return plainToInstance(UserResponseDto, user);
  }
}
```

---

## 2. Hexagonal Architecture (Ports & Adapters)

For complex domains, isolate the domain logic from infrastructure completely.

```
┌─────────────────────────────────────┐
│         Driving Adapters             │
│  (Controllers, CLI, GraphQL resolvers)│
└──────────────┬──────────────────────┘
               │ uses
┌──────────────▼──────────────────────┐
│         Application Core             │
│  ┌─────────────────────────────┐    │
│  │   Domain (entities, VO)     │    │
│  │   Use Cases (services)       │    │
│  │   Ports (interfaces)         │    │
│  └─────────────────────────────┘    │
└──────────────┬──────────────────────┘
               │ implemented by
┌──────────────▼──────────────────────┐
│        Driven Adapters               │
│  (Repositories, Email, External APIs)│
└─────────────────────────────────────┘
```

### Port (interface) — the contract

```typescript
// ports/user-repository.port.ts
export interface IUserRepository {
  findById(id: string): Promise<User | null>;
  findByEmail(email: string): Promise<User | null>;
  save(user: User): Promise<User>;
}
```

### Adapter (implementation) — infrastructure

```typescript
// adapters/typeorm-user.repository.ts
@Injectable()
export class TypeOrmUserRepository implements IUserRepository {
  constructor(
    @InjectRepository(UserEntity)
    private readonly repo: Repository<UserEntity>,
  ) {}

  async findById(id: string): Promise<User | null> {
    const entity = await this.repo.findOne({ where: { id } });
    return entity ? this.toDomain(entity) : null;
  }

  private toDomain(entity: UserEntity): User {
    return new User(entity.id, entity.email, entity.name);
  }
}
```

### Wiring in module

```typescript
@Module({
  providers: [
    UsersService,
    { provide: IUserRepository, useClass: TypeOrmUserRepository },
    { provide: IEmailService, useClass: SMTPEmailService },
  ],
})
export class UsersModule {}
```

**Why this matters:**
- Swap TypeORM for Prisma by changing one line in the module.
- Test `UsersService` with an in-memory fake — no DB needed.
- Domain logic has zero dependency on frameworks.

---

## 3. Domain Layer

Domain entities contain business rules, not just data. They are framework-agnostic.

```typescript
// domain/user.ts — no NestJS decorators, no ORM decorators
export class User {
  private constructor(
    readonly id: string,
    readonly email: string,
    private _name: string,
    private _role: UserRole,
  ) {}

  static create(props: { email: string; name: string }): User {
    // Factory method enforces invariants at creation
    if (!props.email.includes('@')) throw new Error('Invalid email');
    return new User(crypto.randomUUID(), props.email, props.name, 'user');
  }

  get name(): string { return this._name; }

  promoteToAdmin(actor: User): void {
    // Business rule: only admins can promote
    if (actor._role !== 'admin') {
      throw new Error('Only admins can promote');
    }
    this._role = 'admin';
  }
}
```

**Rules:**
- Domain classes have NO framework decorators (`@Injectable`, `@Entity`, `@Column`).
- Domain logic lives in methods, not in services. The `User` class knows its own rules.
- Factory methods (`User.create()`) enforce invariants at construction.
- Entities are immutable from outside — mutate through methods that enforce rules.

---

## 4. When to Apply Hexagonal / DDD

| Project Size | Recommended Architecture |
|---|---|
| Small (CRUD, few entities) | Layered (Controller → Service → Repository) |
| Medium (complex business rules) | Layered + domain entities with logic |
| Large (multiple bounded contexts) | Hexagonal / DDD with ports & adapters |
| Microservices | Hexagonal per service, CQRS for complex event flows |

**Do NOT apply hexagonal architecture to a CRUD app.** It adds ceremony without value. Use it when business rules are complex enough to warrant isolation.

---

## 5. CQRS (Command Query Responsibility Segregation)

For complex state changes with audit trails, split read and write models.

```typescript
// Command — changes state
export class CreateOrderCommand {
  constructor(
    readonly userId: string,
    readonly items: OrderItemDto[],
  ) {}
}

// Command handler
@Injectable()
export class CreateOrderHandler implements ICommandHandler<CreateOrderCommand> {
  async execute(command: CreateOrderCommand): Promise<Order> {
    // Validate, create, persist, emit event
  }
}

// Query — reads state
@Injectable()
export class GetOrderByIdHandler implements IQueryHandler<GetOrderByIdQuery> {
  async execute(query: GetOrderByIdQuery): Promise<OrderResponseDto> {
    // Read from read model (possibly cached/denormalized)
  }
}
```

**Use CQRS when:**
- Write and read models have different performance needs.
- You need audit trails or event sourcing.
- Multiple write paths converge on the same aggregate.

**Do NOT use CQRS when:** the app is simple CRUD. It adds complexity (two models, event bus, eventual consistency) that simple apps don't need.

---

## 6. Folder Structure — Hexagonal

```
src/
├── modules/
│   └── users/
│       ├── application/          # Use cases
│       │   ├── commands/
│       │   ├── queries/
│       │   └── dto/
│       ├── domain/               # Business rules
│       │   ├── user.entity.ts    # Framework-agnostic
│       │   ├── user.repository.ts # Port (interface)
│       │   └── events/
│       ├── infrastructure/       # External concerns
│       │   ├── typeorm-user.repository.ts  # Adapter
│       │   └── smtp-email.service.ts
│       └── presentation/         # HTTP layer
│           ├── users.controller.ts
│           └── users.module.ts
├── shared/                       # Cross-cutting
│   ├── filters/
│   ├── interceptors/
│   └── guards/
└── main.ts
```

---

## Decision Table

| Situation | Pattern |
|---|---|
| Simple CRUD | Layered: Controller → Service → Repository |
| Complex business rules | Domain entities with logic + ports |
| Multiple bounded contexts | Hexagonal with isolated domain modules |
| Need audit trail / event sourcing | CQRS with @nestjs/cqrs |
| Swap database (TypeORM → Prisma) | Port + Adapter (IUserRepository) |
| Test without database | Port + in-memory adapter in tests |
| Fat controller | Move logic to service or domain entity |
