## Blade Conventions

### Project Structure
- Entry point: `Application.java` with `Blade.create().start(Application.class)`
- Controllers: `com.company.app.controller/` with `@Path` annotated classes
- Services: `com.company.app.service/` for business logic
- Models: `com.company.app.model/` for data models
- Templates: `src/main/resources/templates/` for view templates
- Static files: `src/main/resources/static/`
- Configuration: `src/main/resources/application.properties`

### Route and Controller Patterns
- Use `@Path("/users")` on controller classes
- Method annotations: `@GetRoute`, `@PostRoute`, `@PutRoute`, `@DeleteRoute`
- Route parameters: `@PathParam`, `@Param` for query/form parameters
- Return `void` with `response.json(data)` or return a template view name
- Use `RouteContext` for access to request, response, session data

### Middleware (WebHook)
- Implement `WebHook` interface with `before()` and `after()` methods
- Register middleware: `Blade.create().before("/*", new AuthHook())`
- Use `Signature` parameter for route-specific middleware
- Middleware chain: return `true` to continue, `false` to halt

### Request and Response
- Access JSON body: `request.bodyToString()` and parse with JSON library
- Access form data: `request.query("field")`, `request.formString("field")`
- File uploads: `request.fileItem("file")` for multipart handling
- JSON response: `response.json(object)` auto-serializes to JSON
- Set status: `response.status(201)`, headers: `response.header("key", "value")`

### Configuration
- Use `application.properties` or `app.properties` for settings
- Access config: `Blade.create().bootConf(config -> config.get("key"))`
- Environment profiles: `application-dev.properties`, `application-prod.properties`
- Use `@Value("app.setting")` for injecting configuration values into beans

### IoC Container
- Use `@Bean` annotation for service classes managed by Blade's IoC
- Inject dependencies with `@Inject` on fields
- IoC container is lightweight — use it for services and repositories
- Register beans manually for third-party classes: `blade.register(bean)`

### Anti-Patterns to Avoid
- Do not put business logic in controllers — delegate to service classes
- Do not use blocking operations without understanding Blade's threading model
- Do not skip input validation — validate all user input before processing
- Do not hardcode configuration values — use properties files and profiles
- Do not expose internal error details in production responses
