## Ktor Conventions

### Project Structure
- Entry point: `Application.kt` with `embeddedServer(Netty, port = 8080) { module() }.start(wait = true)`
- Modules: `plugins/` for feature installation (serialization, auth, CORS, logging)
- Routes: `routes/{resource}.kt` using `Route` extension functions
- Services: `services/` for business logic
- Models: `models/` for domain and DTO classes
- Configuration: `src/main/resources/application.conf` (HOCON) or `application.yaml`

### Routing Patterns
- Define routes as extension functions on `Route`: `fun Route.userRoutes() { ... }`
- Install in application module: `routing { userRoutes() }`
- Use path parameters: `get("/users/{id}") { val id = call.parameters["id"] }`
- Group routes with `route("/api/v1") { userRoutes(); postRoutes() }`
- Use typed route builders for type-safe URLs with the `Resources` plugin

### Plugin (Feature) Installation
- Install plugins in the application module: `install(ContentNegotiation) { json() }`
- Common plugins: `ContentNegotiation`, `Authentication`, `CORS`, `CallLogging`, `StatusPages`
- Custom plugins: implement `ApplicationPlugin` for reusable cross-cutting concerns
- Order matters: install auth before routes that require it

### Request and Response
- Read JSON body: `call.receive<UserRequest>()` (requires `ContentNegotiation` with `json()`)
- Read parameters: `call.parameters["id"]`, `call.request.queryParameters["page"]`
- Respond: `call.respond(HttpStatusCode.OK, data)` or `call.respondText("ok")`
- Use kotlinx.serialization with `@Serializable` data classes for request/response models
- Validate input manually or with a validation library — Ktor does not validate automatically

### Authentication
- Use `Authentication` plugin: `install(Authentication) { jwt("auth") { ... } }`
- Protect routes: `authenticate("auth") { get("/profile") { ... } }`
- Access principal: `call.principal<JWTPrincipal>()` inside authenticated routes
- Support multiple auth schemes by naming them and applying selectively

### Error Handling
- Use `StatusPages` plugin for centralized error handling
- Map exceptions to responses: `exception<NotFoundException> { call, cause -> call.respond(HttpStatusCode.NotFound, ...) }`
- Define custom exception classes for domain errors
- Always respond with structured JSON error bodies

### Anti-Patterns to Avoid
- Do not use blocking code in route handlers — Ktor runs on coroutines
- Do not skip `ContentNegotiation` installation — manual JSON serialization is error-prone
- Do not use global mutable state — use dependency injection or application attributes
- Do not catch `CancellationException` — it breaks coroutine cancellation
- Do not forget to close `HttpClient` instances — use a shared client via DI
