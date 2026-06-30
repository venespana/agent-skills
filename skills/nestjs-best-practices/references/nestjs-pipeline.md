# NestJS DTOs, Validation & Pipes

Input validation and transformation patterns. Based on official NestJS docs and class-validator.

---

## 1. DTOs with class-validator

**Every endpoint that accepts input must have a DTO with validation decorators.** No exceptions.

```typescript
import { IsEmail, IsString, MinLength, MaxLength, IsOptional, IsEnum } from 'class-validator';

export class CreateUserDto {
  @IsEmail()
  email: string;

  @IsString()
  @MinLength(8)
  @MaxLength(128)
  password: string;

  @IsString()
  @MinLength(1)
  @MaxLength(100)
  name: string;

  @IsEnum(['admin', 'user', 'guest'])
  @IsOptional()
  role?: 'admin' | 'user' | 'guest';
}
```

**Rules:**
- Every property has at least one validation decorator.
- Optional fields use `@IsOptional()`.
- String fields have `@MaxLength` to prevent oversized payloads.
- Enums use `@IsEnum()` not bare string types.

---

## 2. Global ValidationPipe

Register `ValidationPipe` globally with strict settings.

```typescript
// main.ts
async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,          // Strip unknown properties
      forbidNonWhitelisted: true, // Throw on unknown properties
      transform: true,          // Transform payloads to DTO instances
      transformOptions: {
        enableImplicitConversion: true, // Convert types based on TS types
      },
    }),
  );

  await app.listen(process.env.PORT ?? 3000);
}
```

**Why `whitelist: true`**: prevents mass assignment attacks. Unknown properties are silently stripped.

**Why `forbidNonWhitelisted: true`**: makes it explicit — if a client sends an unknown field, they get a 400 error instead of silent stripping. Use this for APIs where client bugs should surface.

---

## 3. DTO Inheritance

Use inheritance to share validation across DTOs.

```typescript
// Base DTO with common fields
export class PaginationDto {
  @IsInt()
  @Min(1)
  @IsOptional()
  page?: number = 1;

  @IsInt()
  @Min(1)
  @Max(100)
  @IsOptional()
  limit?: number = 20;
}

// Extends for specific endpoints
export class ListUsersDto extends PaginationDto {
  @IsString()
  @IsOptional()
  search?: string;
}
```

---

## 4. Nested Validation

Use `@ValidateNested()` + `@Type()` for nested objects.

```typescript
import { ValidateNested } from 'class-validator';
import { Type } from 'class-transformer';

export class CreateOrderDto {
  @ValidateNested({ each: true })
  @Type(() => OrderItemDto)
  items: OrderItemDto[];
}

export class OrderItemDto {
  @IsUUID()
  productId: string;

  @IsInt()
  @Min(1)
  quantity: number;
}
```

**Without `@Type()`, nested validation silently fails** — `class-transformer` does not know to convert plain objects into the nested DTO class.

---

## 5. Parameter Validation with Built-in Pipes

Use NestJS built-in pipes for route parameter validation.

```typescript
@Controller('users')
export class UsersController {
  // GOOD — ParseUUIDPipe validates the param
  @Get(':id')
  findOne(@Param('id', ParseUUIDPipe) id: string) {
    return this.usersService.findById(id);
  }

  // GOOD — ParseIntPipe validates and transforms
  @Get()
  findAll(@Query('page', ParseIntPipe) page: number) {
    return this.usersService.findAll(page);
  }
}
```

**Never accept `@Param('id')` as a bare string without validation.** Always use `ParseUUIDPipe`, `ParseIntPipe`, or a custom pipe.

---

## 6. Custom Pipes

Create custom pipes for domain-specific validation or transformation.

```typescript
@Injectable()
export class PasswordStrengthPipe implements PipeTransform<string, string> {
  transform(value: string): string {
    if (value.length < 8) {
      throw new BadRequestException('Password must be at least 8 characters');
    }
    if (!/[A-Z]/.test(value)) {
      throw new BadRequestException('Password must contain an uppercase letter');
    }
    return value; // Pass through unchanged
  }
}

// Usage
@Post('register')
register(@Body('password', PasswordStrengthPipe) password: string) {
  // password is guaranteed to meet strength requirements
}
```

---

## 7. Response Serialization

Use `class-transformer` `@Exclude()` / `@Expose()` to control what leaves the API.

```typescript
import { Exclude, Expose } from 'class-transformer';

export class UserResponseDto {
  @Expose()
  id: string;

  @Expose()
  email: string;

  @Expose()
  name: string;

  @Exclude() // Never send password hash to client
  passwordHash: string;
}

// In controller
@Get(':id')
async findOne(@Param('id', ParseUUIDPipe) id: string): Promise<UserResponseDto> {
  const user = await this.usersService.findById(id);
  return plainToInstance(UserResponseDto, user, { excludeExtraneousValues: true });
}
```

**Always define response DTOs.** Never return raw entity objects — they may leak internal fields.

---

## Decision Table

| Situation | Pattern |
|---|---|
| Endpoint accepts body input | DTO + class-validator decorators |
| Unknown properties in payload | `whitelist: true` + `forbidNonWhitelisted: true` |
| Nested objects in body | `@ValidateNested()` + `@Type()` |
| Route param UUID | `ParseUUIDPipe` |
| Route param integer | `ParseIntPipe` |
| Custom domain validation | Custom `PipeTransform` |
| Response to client | Response DTO + `@Expose()` / `@Exclude()` |
| Shared pagination fields | DTO inheritance |
