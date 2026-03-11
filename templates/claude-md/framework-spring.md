## Spring Boot Conventions

### Project Structure
- Follow package-by-feature: `com.company.app.{feature}` with controller, service, repository, model, dto
- Configuration: `src/main/resources/application.yml` with profile-specific overrides (`application-dev.yml`)
- Entry point: `@SpringBootApplication` class in the root package
- Shared code: `com.company.app.common` for exceptions, base classes, and utilities
- Database migrations: `src/main/resources/db/migration/` using Flyway or Liquibase

### Controller Patterns
- Use `@RestController` for APIs; `@Controller` for MVC views
- Map at class level: `@RequestMapping("/api/v1/users")` — method level: `@GetMapping`, `@PostMapping`
- Validate request bodies with `@Valid` and Jakarta Validation annotations on DTOs
- Return `ResponseEntity<T>` for explicit status codes; direct return for 200
- Use `@PathVariable`, `@RequestParam`, `@RequestBody` for input binding

### Service and Repository Patterns
- Service classes: `@Service` with constructor injection (no `@Autowired` on fields)
- Repositories: extend `JpaRepository<Entity, ID>` or `CrudRepository`
- Use `@Transactional` on service methods, not on repositories or controllers
- Read-only transactions: `@Transactional(readOnly = true)` for query methods
- Define custom queries with `@Query` annotation or query methods naming convention

### Dependency Injection
- Use constructor injection exclusively — never field injection (`@Autowired` on fields)
- If a class has only one constructor, `@Autowired` is optional (Spring auto-detects)
- Use `@Configuration` classes with `@Bean` methods for third-party library wiring
- Use profiles (`@Profile("dev")`) for environment-specific beans

### Error Handling
- Use `@RestControllerAdvice` for global exception handling
- Define domain exception hierarchy: `AppException -> NotFoundException, ValidationException`
- Map exceptions to HTTP responses with `@ExceptionHandler`
- Return consistent error response body: `{ timestamp, status, error, message, path }`
- Never expose stack traces in production responses

### Testing
- Unit tests: `@ExtendWith(MockitoExtension.class)` with `@Mock` and `@InjectMocks`
- Integration tests: `@SpringBootTest` with `@AutoConfigureMockMvc` and `MockMvc`
- Database tests: `@DataJpaTest` with embedded H2 or Testcontainers
- Use `@TestContainers` for integration tests against real databases

### Anti-Patterns to Avoid
- Do not inject `EntityManager` in controllers — use repositories and services
- Do not return JPA entities directly from controllers — use DTOs
- Do not use `@Autowired` on fields — use constructor injection
- Do not catch and re-throw exceptions without adding context
- Do not skip database migrations — use Flyway or Liquibase
