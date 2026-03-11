## NestJS Conventions

### Project Structure
- Follow NestJS module-per-feature pattern: `src/{feature}/{feature}.module.ts`
- Each feature module contains: controller, service, DTOs, entities, and spec files
- Shared modules in `src/common/` or `src/shared/` (guards, interceptors, pipes, decorators)
- Configuration: use `@nestjs/config` with typed config objects, not raw `process.env`
- Database entities in `src/{feature}/entities/`; DTOs in `src/{feature}/dto/`

### Module Patterns
- Every feature gets its own module registered in `AppModule`
- Use `forRoot()`/`forRootAsync()` for global configuration modules (database, auth, cache)
- Use `forFeature()` for feature-scoped registrations (TypeORM repositories, Mongoose models)
- Export only what other modules need — keep module internals private
- Use dynamic modules for configurable, reusable modules

### Controller and Service Patterns
- Controllers handle HTTP concerns only: parsing input, calling services, formatting responses
- Services contain all business logic; inject repositories and other services via constructor
- Use DTOs with `class-validator` decorators for request validation
- Use `class-transformer` with `@Exclude()` and `@Expose()` for response serialization
- Apply `ValidationPipe` globally with `whitelist: true` and `forbidNonWhitelisted: true`

### Dependency Injection
- Use constructor injection exclusively; avoid `@Inject()` unless using custom providers
- Register providers in the module's `providers` array
- Use custom providers (`useFactory`, `useClass`, `useValue`) for configuration and abstraction
- Scope: default to singleton; use `REQUEST` scope only when truly needed (it impacts performance)

### Guards, Interceptors, and Pipes
- Guards for authorization: `@UseGuards(AuthGuard)` on controllers or routes
- Interceptors for cross-cutting concerns: logging, caching, response transformation
- Pipes for validation and transformation: apply globally or per-parameter
- Execution order: Middleware -> Guards -> Interceptors (before) -> Pipes -> Handler -> Interceptors (after)

### Testing
- Unit test services with `Test.createTestingModule()` and mocked dependencies
- E2E test API endpoints with `@nestjs/testing` and `supertest`
- Mock repositories and external services; never hit real databases in unit tests

### Anti-Patterns to Avoid
- Do not inject `Request` or `Response` directly into services — services must be HTTP-agnostic
- Do not use `@Req()` and `@Res()` when NestJS decorators suffice (`@Body()`, `@Param()`, `@Query()`)
- Do not put business logic in controllers, guards, or interceptors
- Do not create circular module dependencies — refactor into a shared module
