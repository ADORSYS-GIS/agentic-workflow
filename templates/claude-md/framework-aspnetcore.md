## ASP.NET Core Conventions

### Project Structure
- Follow feature-slice or vertical-slice architecture: group by feature, not by layer
- Controllers: `Controllers/{Feature}Controller.cs` or use Minimal APIs in `Program.cs`
- Services: `Services/` for business logic with interface + implementation
- Models: `Models/` for domain entities; `DTOs/` for request/response shapes
- Data: `Data/` for `DbContext`, repositories, and migrations
- Middleware: `Middleware/` for custom middleware classes
- Configuration: `appsettings.json` with environment overrides (`appsettings.Development.json`)

### Controller Patterns
- Inherit from `ControllerBase` for APIs (not `Controller` — that adds view support)
- Use `[ApiController]` attribute for automatic model validation and binding
- Route at class level: `[Route("api/[controller]")]`; action level: `[HttpGet("{id}")]`
- Return `ActionResult<T>` for typed responses: `Ok(data)`, `NotFound()`, `BadRequest(errors)`
- Use `CancellationToken` parameter in all async actions for request cancellation support

### Minimal APIs (NET 6+)
- Define endpoints: `app.MapGet("/users/{id}", async (int id, IUserService svc) => ...)`
- Group endpoints: `app.MapGroup("/api/users").MapGet("/", ListUsers).MapPost("/", CreateUser)`
- Use `TypedResults` for explicit return types: `TypedResults.Ok(data)`, `TypedResults.NotFound()`
- Filter: use endpoint filters for validation, logging, and auth on specific endpoints
- Prefer Minimal APIs for microservices; controllers for larger applications with complex routing

### Dependency Injection
- Register in `Program.cs`: `builder.Services.AddScoped<IUserService, UserService>()`
- Lifetimes: `AddTransient` (per-resolve), `AddScoped` (per-request), `AddSingleton` (per-app)
- Use `IOptions<T>` / `IOptionsSnapshot<T>` for configuration injection
- Register `HttpClient` with `AddHttpClient<T>()` — never create `HttpClient` manually

### Middleware Pipeline
- Order matters: Exception handler -> HTTPS redirect -> Static files -> Routing -> Auth -> Endpoints
- Custom middleware: `app.Use(async (context, next) => { ... await next(context); ... })`
- Or implement `IMiddleware` for testable, DI-aware middleware classes
- Use `app.UseExceptionHandler()` for global error handling in production

### Error Handling
- Use `ProblemDetails` (RFC 7807) for standardized error responses
- Configure: `builder.Services.AddProblemDetails()` with custom mappings
- Use `IExceptionHandler` (NET 8+) for structured exception-to-response mapping
- Validate with `FluentValidation` or Data Annotations; `[ApiController]` returns 400 automatically

### Anti-Patterns to Avoid
- Do not use `HttpClient` directly — use `IHttpClientFactory` to prevent socket exhaustion
- Do not use `async void` — only `async Task` for async methods (except event handlers)
- Do not call `.Result` or `.Wait()` on tasks — it causes deadlocks; always `await`
- Do not put business logic in controllers — keep them as thin orchestrators
- Do not skip `CancellationToken` in async methods — it enables request cancellation
