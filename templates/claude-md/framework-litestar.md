## Litestar Conventions

### Project Structure
- Entry point: `app/main.py` with `Litestar(route_handlers=[...])` application
- Controllers: `app/controllers/{resource}.py` using `Controller` classes
- DTOs: `app/dto/` for data transfer objects (built-in Litestar DTO layer)
- Models: `app/models/` for SQLAlchemy or other ORM models
- Services: `app/services/` for business logic
- Dependencies: `app/dependencies.py` for shared dependency providers
- Guards: `app/guards/` for authentication and authorization

### Controller Patterns
- Use `Controller` classes with `path` attribute for resource grouping
- Methods: `@get()`, `@post()`, `@put()`, `@patch()`, `@delete()` decorators
- Return type annotations drive response serialization — annotate all handlers
- Use `Controller.dependencies` for controller-scoped dependency injection
- Organize one controller per resource file

### DTO Layer
- Use Litestar's built-in DTO system for request parsing and response filtering
- Define `DTOConfig(exclude={"password"})` to control field exposure
- Use `SQLAlchemyDTO` for automatic ORM model serialization
- Use `DataclassDTO`, `MsgspecDTO`, or `PydanticDTO` based on your model library
- Mark fields with `DTOField(mark=Mark.READ_ONLY)` for auto-generated fields

### Dependency Injection
- Define dependencies as functions or classes; register via `dependencies` parameter
- Use `Provide()` wrapper for dependency configuration
- Support for sync and async dependency providers
- Use `yield` dependencies for resource lifecycle management (DB sessions)
- Dependencies are resolved per-request by default

### Data Validation
- Litestar validates request bodies automatically based on handler type annotations
- Use `dataclasses`, `msgspec.Struct`, `attrs`, or `Pydantic` models for request bodies
- Prefer `msgspec.Struct` for best performance (fastest serialization)
- Path, query, and header parameters are validated from type annotations

### Error Handling
- Raise `HTTPException` or specific subclasses (`NotFoundException`, `ValidationException`)
- Register exception handlers: `Litestar(exception_handlers={CustomError: handler})`
- Return structured error responses with consistent shape
- Use guards for authorization — raise `NotAuthorizedException`

### Anti-Patterns to Avoid
- Do not bypass the DTO layer by returning raw dicts — use typed models
- Do not put business logic in controllers — delegate to services
- Do not use synchronous database calls in async handlers
- Do not skip return type annotations — they drive serialization and OpenAPI docs
