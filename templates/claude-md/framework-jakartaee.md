## Jakarta EE Conventions

### Project Structure
- Follow package-by-feature: `com.company.app.{feature}` with resource, service, entity, dto
- Deployment descriptor: `src/main/webapp/WEB-INF/` for web.xml (if needed)
- Configuration: `src/main/resources/META-INF/persistence.xml` for JPA
- Beans: `src/main/resources/META-INF/beans.xml` for CDI configuration
- Use WAR packaging for servlet containers; JAR for microprofile runtimes

### REST Resources (JAX-RS)
- Annotate application class: `@ApplicationPath("/api")` extends `Application`
- Resource classes: `@Path("/users")` with `@GET`, `@POST`, `@PUT`, `@DELETE`
- Use `@Consumes(MediaType.APPLICATION_JSON)` and `@Produces(MediaType.APPLICATION_JSON)`
- Input binding: `@PathParam`, `@QueryParam`, `@HeaderParam`, `@BeanParam`
- Validate with `@Valid` on method parameters using Bean Validation annotations

### CDI (Dependency Injection)
- Use `@Inject` for dependency injection — prefer constructor injection
- Scopes: `@RequestScoped` (per HTTP request), `@ApplicationScoped` (singleton), `@SessionScoped`
- Use `@Produces` methods in `@ApplicationScoped` beans for factory patterns
- Qualifiers: use `@Named` or custom qualifiers to distinguish implementations
- Events: `@Inject Event<OrderCreated>` for decoupled communication between components

### JPA Patterns
- Define entities with `@Entity`, `@Table`, `@Id`, `@GeneratedValue`
- Use named queries: `@NamedQuery(name = "User.findByEmail", query = "...")`
- Inject `EntityManager` via `@PersistenceContext` in DAOs
- Transaction management: `@Transactional` on service methods (JTA)
- Use DTOs for API responses — never expose entity relationships directly

### Security (Jakarta Security)
- Use `@RolesAllowed`, `@PermitAll`, `@DenyAll` on resource methods
- Configure identity stores with `@DatabaseIdentityStoreDefinition` or `@LdapIdentityStoreDefinition`
- Use `SecurityContext` injection for programmatic security checks
- HTTPS enforcement: configure at the container level, not in application code

### Anti-Patterns to Avoid
- Do not use `EntityManager` directly in REST resources — use a service/repository layer
- Do not return JPA entities from REST endpoints — use DTOs to avoid lazy loading issues
- Do not mix CDI and EJB annotations without understanding the differences
- Do not use `@Stateful` session beans for REST APIs — they are request/response, not session-based
- Do not put business logic in REST resource classes — delegate to services
