## Micronaut Conventions

### Project Structure
- Follow package-by-feature: `com.company.app.{feature}` with controller, service, repository, model
- Configuration: `src/main/resources/application.yml` with environment-specific overrides
- Entry point: `Application.java` with `Micronaut.run(Application.class)`
- Use `@Introspected` on POJOs for reflection-free bean introspection (needed for GraalVM)

### Controller Patterns
- Use `@Controller("/api/users")` for REST endpoints
- Methods: `@Get("/{id}")`, `@Post`, `@Put("/{id}")`, `@Delete("/{id}")`
- Request binding: `@PathVariable`, `@QueryValue`, `@Body`
- Validate with `@Valid` on `@Body` parameters using Jakarta Validation annotations
- Return `HttpResponse<T>` for explicit status codes; return `T` directly for 200

### Dependency Injection
- Micronaut DI is compile-time — no runtime reflection (fast startup, low memory)
- Use constructor injection (default); `@Inject` on fields only when necessary
- Scopes: `@Singleton` (default), `@RequestScope`, `@Prototype`
- Use `@Factory` classes with `@Bean` methods for third-party library wiring
- Conditional beans: `@Requires(env = "production")`, `@Requires(beans = DataSource.class)`

### Data Access
- Use Micronaut Data: `@Repository interface UserRepository extends CrudRepository<User, Long>`
- Define queries with method names: `findByEmailAndStatus(String email, Status status)`
- Custom queries: `@Query("SELECT u FROM User u WHERE u.active = true")`
- Use `@Transactional` on service methods for transaction management
- Configure connection pools in `application.yml` under `datasources.default`

### Reactive Support
- Return `Mono<T>`/`Flux<T>` (Reactor) or `Publisher<T>` for reactive endpoints
- Use Micronaut's reactive HTTP client: `@Client("/api") interface UserClient`
- Declarative HTTP clients: define interfaces annotated with `@Client` for external API calls
- Use `@Retryable` and `@CircuitBreaker` for resilient HTTP client calls

### Testing
- Use `@MicronautTest` for integration tests with automatic application context
- Mock beans with `@MockBean(UserService.class)` for isolated testing
- Use Testcontainers for database and service dependencies
- Embedded server: `@MicronautTest` starts an embedded HTTP server automatically

### Anti-Patterns to Avoid
- Do not use runtime reflection APIs — they break GraalVM native image compilation
- Do not forget `@Introspected` on DTOs — Micronaut needs it for compile-time introspection
- Do not use `@PostConstruct` for complex initialization — use `ApplicationEventListener<StartupEvent>`
- Do not skip declarative HTTP clients — manual `HttpClient` usage is verbose and error-prone
