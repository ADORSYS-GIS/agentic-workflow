## Vapor Conventions

### Project Structure
- Entry point: `Sources/App/entrypoint.swift` with `@main` and Vapor `Application`
- Configuration: `Sources/App/configure.swift` for app setup (routes, middleware, database)
- Routes: `Sources/App/Routes/` or `Sources/App/Controllers/` for route handlers
- Controllers: `Sources/App/Controllers/{Resource}Controller.swift` grouping related endpoints
- Models: `Sources/App/Models/` for Fluent ORM models
- Migrations: `Sources/App/Migrations/` for database schema changes
- DTOs: `Sources/App/DTOs/` for request/response `Content` types

### Route and Controller Patterns
- Register routes in `routes.swift`: `app.get("users", use: UserController().index)`
- Controllers: implement `RouteCollection` protocol with `boot(routes:)` method
- Group routes: `let users = routes.grouped("api", "v1", "users")`
- Protected routes: `routes.grouped(UserToken.authenticator(), User.guardMiddleware())`
- Handlers: `func index(req: Request) async throws -> [UserDTO]`
- Path parameters: `req.parameters.get("id", as: UUID.self)`

### Fluent ORM
- Models: `final class User: Model, Content { @ID var id: UUID?; @Field(key: "name") var name: String }`
- Property wrappers: `@ID`, `@Field`, `@OptionalField`, `@Parent`, `@Children`, `@Siblings`
- Migrations: `struct CreateUser: AsyncMigration { func prepare(on database: Database) async throws { ... } }`
- Queries: `User.query(on: req.db).filter(\.$active == true).all()`
- Eager loading: `User.query(on: req.db).with(\.$posts).first()`
- Always use DTOs for API responses — do not expose model relationships directly

### Request and Response
- Request body: `let dto = try req.content.decode(CreateUserDTO.self)` using `Content` protocol
- Response: return any type conforming to `Content` (auto-serializes to JSON)
- Validation: `try CreateUserDTO.validate(content: req)` with `Validatable` protocol
- Custom responses: `return Response(status: .created, body: .init(data: encoded))`

### Authentication
- Use Vapor's built-in auth: `ModelAuthenticatable`, `ModelTokenAuthenticatable`
- Bearer token auth: `User.authenticator()` middleware validates tokens automatically
- Session auth: `User.sessionAuthenticator()` for web applications
- Access user in handler: `let user = try req.auth.require(User.self)`
- Guard middleware: ensures authentication before reaching the handler

### Error Handling
- Throw `Abort(.notFound, reason: "User not found")` for HTTP errors
- Custom errors: conform to `AbortError` or `DebuggableError`
- Vapor's error middleware catches thrown errors and returns JSON responses
- Use `do`/`catch` for recoverable errors; `throw` for request-terminating errors

### Anti-Patterns to Avoid
- Do not block the event loop — use `async`/`await` for all I/O operations
- Do not return Fluent models directly from endpoints — use DTOs to control the response shape
- Do not skip migrations — manual database changes will drift from the codebase
- Do not use `try!` or `!` force-unwrap in handlers — throw proper errors instead
- Do not forget to `await` database queries — they are asynchronous
