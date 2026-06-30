# NestJS Cross-Cutting Concerns

Guards, interceptors, middleware, and exception filters. When to use each, based on official docs.

---

## 1. The Execution Order

```
Request
  → Middleware          (Express-level, runs first)
    → Guards            (Authorization: can this request proceed?)
      → Interceptors (pre)  (Logging, caching, transformation)
        → Pipes        (Validation, parameter transformation)
          → Controller  (Your handler)
        ← Return value
      ← Interceptors (post) (Response transformation, caching)
    ← Exception Filter  (Only if an error was thrown)
  ← Response
```

---

## 2. Guards — Authorization

Guards decide whether a request can proceed. Use for auth and RBAC.

```typescript
@Injectable()
export class JwtAuthGuard implements CanActivate {
  constructor(private jwtService: JwtService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const token = this.extractToken(request);
    if (!token) return false;

    try {
      const payload = await this.jwtService.verifyAsync(token);
      request.user = payload;
      return true;
    } catch {
      return false;
    }
  }

  private extractToken(request: Request): string | undefined {
    const [type, token] = request.headers.authorization?.split(' ') ?? [];
    return type === 'Bearer' ? token : undefined;
  }
}
```

### Role-based Guard with metadata

```typescript
// Decorator to mark required roles
export const ROLES_KEY = 'roles';
export const Roles = (...roles: string[]) => SetMetadata(ROLES_KEY, roles);

// Guard that checks roles
@Injectable()
export class RolesGuard implements CanActivate {
  constructor(private reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const requiredRoles = this.reflector.getAllAndOverride<string[]>(ROLES_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    if (!requiredRoles) return true;

    const { user } = context.switchToHttp().getRequest();
    return requiredRoles.some((role) => user.roles?.includes(role));
  }
}

// Usage
@Controller('admin')
@UseGuards(JwtAuthGuard, RolesGuard)
export class AdminController {
  @Get('users')
  @Roles('admin')
  findAllUsers() {
    return this.adminService.findAllUsers();
  }
}
```

### Global Guards

Register via `APP_GUARD` token (enables DI).

```typescript
@Module({
  providers: [
    { provide: APP_GUARD, useClass: JwtAuthGuard },
  ],
})
export class AppModule {}
```

---

## 3. Interceptors — AOP

Interceptors wrap controller handlers. Use for: logging, caching, response transformation, timeout.

### Logging Interceptor

```typescript
@Injectable()
export class LoggingInterceptor implements NestInterceptor {
  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const request = context.switchToHttp().getRequest();
    const method = request.method;
    const url = request.url;
    const now = Date.now();

    return next.handle().pipe(
      tap(() => {
        const duration = Date.now() - now;
        // Use structured logger, not console.log
        Logger.log(`${method} ${url} ${duration}ms`, 'HTTP');
      }),
    );
  }
}
```

### Timeout Interceptor

```typescript
@Injectable()
export class TimeoutInterceptor implements NestInterceptor {
  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    return next.handle().pipe(
      timeout(5000),
      catchError((err) => {
        if (err instanceof TimeoutError) {
          throw new RequestTimeoutException('Request took too long');
        }
        throw err;
      }),
    );
  }
}
```

### Response Mapping Interceptor

```typescript
@Injectable()
export class ResponseFormatInterceptor<T> implements NestInterceptor<T, { data: T }> {
  intercept(context: ExecutionContext, next: CallHandler<T>): Observable<{ data: T }> {
    return next.handle().pipe(
      map((data) => ({ data })),
    );
  }
}
```

### Global Interceptors

```typescript
@Module({
  providers: [
    { provide: APP_INTERCEPTOR, useClass: LoggingInterceptor },
    { provide: APP_INTERCEPTOR, useClass: TimeoutInterceptor },
  ],
})
export class AppModule {}
```

---

## 4. Middleware — Express-Level

Middleware runs before guards. Use for: request logging, CORS, body parsing, rate limiting.

```typescript
@Injectable()
export class RateLimitMiddleware implements NestMiddleware {
  use(req: Request, res: Response, next: NextFunction) {
    // Rate limiting logic
    next();
  }
}

// Register in module
export class AppModule implements NestModule {
  configure(consumer: MiddlewareConsumer) {
    consumer
      .apply(RateLimitMiddleware, HelmetMiddleware)
      .forRoutes('*');
  }
}
```

### Middleware vs Interceptor — when to use each?

| Concern | Use Middleware | Use Interceptor |
|---|---|---|
| Needs to run before guards | Yes | No |
| Needs response to be available | No (runs before handler) | Yes |
| Needs RxJS / Observable | No | Yes |
| Response transformation | No | Yes |
| Caching | No | Yes |
| Rate limiting | Yes | No |
| Security headers | Yes | No |

**Default to interceptors.** Only use middleware when you need Express-level access (before NestJS guards/pipes).

---

## 5. Exception Filters

Catch thrown exceptions and map them to HTTP responses.

### Custom Domain Exceptions

Define domain-specific exceptions that extend HttpException.

```typescript
export class UserNotFoundException extends NotFoundException {
  constructor(id: string) {
    super(`User with ID ${id} not found`);
  }
}

export class EmailAlreadyExistsException extends ConflictException {
  constructor(email: string) {
    super(`Email ${email} is already registered`);
  }
}
```

### Global Exception Filter

```typescript
@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
  constructor(private readonly httpAdapterHost: HttpAdapterHost) {}

  catch(exception: unknown, host: ArgumentsHost): void {
    const { httpAdapter } = this.httpAdapterHost;
    const ctx = host.switchToHttp();

    const status =
      exception instanceof HttpException
        ? exception.getStatus()
        : HttpStatus.INTERNAL_SERVER_ERROR;

    const responseBody = {
      statusCode: status,
      timestamp: new Date().toISOString(),
      path: httpAdapter.getRequestUrl(ctx.getRequest()),
      message: exception instanceof Error ? exception.message : 'Internal error',
    };

    // Log the full exception server-side; never send stack traces to client
    Logger.error(exception);

    httpAdapter.reply(ctx.getResponse(), responseBody, status);
  }
}
```

### Register globally

```typescript
// main.ts
const app = await NestFactory.create(AppModule);
const { httpAdapterHost } = app.get(HttpAdapterHost);
app.useGlobalFilters(new AllExceptionsFilter(httpAdapterHost));
```

---

## 6. Cross-Cutting Registration Summary

| Concern | Global Registration | Scope |
|---|---|---|
| Validation | `APP_PIPE` + `ValidationPipe` | Every request |
| Auth | `APP_GUARD` + `JwtAuthGuard` | Every request |
| Logging | `APP_INTERCEPTOR` + `LoggingInterceptor` | Every request |
| Timeout | `APP_INTERCEPTOR` + `TimeoutInterceptor` | Every request |
| Error mapping | `useGlobalFilters()` | Unhandled exceptions |
| Rate limit | Middleware in `AppModule.configure()` | Route-level |

**Prefer `APP_*` tokens over `useGlobal*()` methods** — the token approach enables dependency injection.
