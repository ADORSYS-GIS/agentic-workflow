## Spring Boot (Kotlin) Conventions

### Project Structure
- Same as Spring Boot Java but with `.kt` files
- Package-by-feature: `com.company.app.{feature}` with controller, service, repository, model, dto
- Configuration: `src/main/resources/application.yml` with profile overrides
- Use Kotlin-specific Spring extensions and DSLs
- Entry point: `@SpringBootApplication class Application` with `fun main(args: Array<String>) { runApplication<Application>(*args) }`

### Kotlin-Specific Patterns
- Use `data class` for DTOs and request/response models — not for JPA entities
- Use Kotlin `val`/`var` for bean properties; `lateinit var` for Spring-injected fields (prefer constructor injection)
- Use extension functions to add utility methods to Spring classes
- Use `when` expressions for mapping enum values and handling sealed class hierarchies
- Use named arguments for improved readability in builder-like configurations

### Controller Patterns
- Use `@RestController` with `@RequestMapping` at class level
- Return nullable types for optional resources: `fun getUser(@PathVariable id: Long): UserDto?`
- Use Kotlin coroutines with WebFlux: `suspend fun getUser(): UserDto`
- Validate with `@Valid` on request body parameters
- Use the router DSL for functional endpoint definition: `router { GET("/users", ::listUsers) }`

### Service and Repository Patterns
- Constructor injection is the default — Kotlin's primary constructor makes this clean
- Repository: `interface UserRepository : JpaRepository<User, Long>` with Kotlin method syntax
- Use `?:` (elvis) for fallback: `repository.findByIdOrNull(id) ?: throw NotFoundException()`
- Use Spring Data's Kotlin extension `findByIdOrNull()` instead of `findById().orElse(null)`
- Use `@Transactional` on service classes or methods, not on repositories

### Coroutines with Spring WebFlux
- Use `suspend` functions in controllers and services for reactive, coroutine-based handlers
- Use `Flow<T>` instead of `Flux<T>` for streaming responses
- Use `coRouter { }` DSL for coroutine-based functional routing
- Use `awaitSingle()`, `awaitFirstOrNull()` to bridge Reactor types to coroutines

### JPA Entity Patterns
- DO NOT use `data class` for JPA entities (breaks Hibernate proxy and equals/hashCode semantics)
- Use `open class` with `open` properties or the `kotlin-allopen` compiler plugin with JPA annotations
- Use `kotlin-noarg` plugin with `@Entity` annotation for no-arg constructor generation
- Override `equals()` and `hashCode()` based on business key, not entity ID

### Anti-Patterns to Avoid
- Do not use `data class` for JPA entities — use regular classes with the allopen/noarg plugins
- Do not use `!!` operator — prefer null-safe calls, elvis, or explicit validation
- Do not mix coroutines and blocking code on the same thread
- Do not forget the `kotlin-spring` compiler plugin — Spring needs open classes for proxying
- Do not use `companion object` for static utility methods that do not need class context — use top-level functions
