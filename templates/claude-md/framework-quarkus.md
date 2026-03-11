## Quarkus Conventions

### Project Structure
- Follow package-by-feature: `com.company.app.{feature}` with resource, service, entity, dto
- Configuration: `src/main/resources/application.properties` or `application.yml`
- Profile-specific config: `%dev.`, `%test.`, `%prod.` prefixes in properties
- Native image: ensure all reflection-using classes are registered or use `@RegisterForReflection`

### Resource (Controller) Patterns
- Use Jakarta REST annotations: `@Path`, `@GET`, `@POST`, `@PUT`, `@DELETE`
- CDI injection: `@Inject` on fields or constructor; prefer constructor injection
- Return `Response` for explicit status codes; return entity directly for 200
- Use `@Valid` with Hibernate Validator for input validation
- Reactive: use `@Path` with `Uni<T>` or `Multi<T>` return types for reactive endpoints

### Reactive vs Imperative
- Choose one model per service: reactive (Mutiny `Uni`/`Multi`) or imperative
- Reactive: use Quarkus Reactive routes, RESTEasy Reactive, reactive Hibernate
- Imperative: use traditional blocking approach with virtual threads (Quarkus 3+)
- Use `@RunOnVirtualThread` to run blocking code on virtual threads without manual thread management
- Never block on a reactive thread (no `Thread.sleep()`, no blocking I/O)

### Panache (Database)
- Use Panache for simplified data access: `PanacheEntity` (active record) or `PanacheRepository` (repository pattern)
- Prefer repository pattern for better testability: `@ApplicationScoped class UserRepository implements PanacheRepository<User>`
- Use Panache's query methods: `find("status", Status.ACTIVE)`, `list("order by name")`
- Transactions: `@Transactional` on service methods
- Use `PanacheEntityBase` with custom ID types when UUID or non-Long IDs are needed

### CDI and Configuration
- Use `@ApplicationScoped` for most beans (singleton per app)
- Use `@RequestScoped` only when per-request state is needed
- Configuration injection: `@ConfigProperty(name = "app.feature.enabled")` or `@ConfigMapping`
- Use `@ConfigMapping` interfaces for structured, type-safe configuration groups

### Testing
- Use `@QuarkusTest` for integration tests with full application context
- Use `@QuarkusTestResource` for external services (databases, message brokers)
- Mock CDI beans with `@InjectMock` (using `quarkus-junit5-mockito`)
- Use Dev Services for automatic provisioning of databases, Kafka, Redis during testing

### Anti-Patterns to Avoid
- Do not use reflection-heavy libraries without `@RegisterForReflection` (breaks native image)
- Do not use `@Singleton` when `@ApplicationScoped` suffices — they differ in proxy behavior
- Do not mix reactive and blocking code on the same thread
- Do not skip Dev Services — they eliminate manual test infrastructure setup
