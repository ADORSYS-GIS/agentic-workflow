## FastAPI Conventions

### Project Structure
- Entry point: `app/main.py` with `FastAPI()` instance and router includes
- Routers: `app/routers/{resource}.py` using `APIRouter(prefix="/resources", tags=["resources"])`
- Models: `app/models/` for SQLAlchemy/Tortoise ORM models
- Schemas: `app/schemas/` for Pydantic request/response models
- Services: `app/services/` for business logic
- Dependencies: `app/dependencies.py` for shared dependency injection functions
- Configuration: `app/config.py` using Pydantic `BaseSettings`

### Pydantic Models
- Define separate schemas for create, update, and response: `UserCreate`, `UserUpdate`, `UserResponse`
- Use `model_config = ConfigDict(from_attributes=True)` for ORM model conversion
- Use `Field()` with `description`, `examples`, and validation constraints for OpenAPI docs
- Use `Annotated[str, Field(min_length=1, max_length=100)]` for reusable field types
- Never expose internal fields (password hashes, internal IDs) in response models

### Dependency Injection
- Use `Depends()` for shared logic: database sessions, auth, pagination, rate limiting
- Define dependencies as functions or classes with `__call__`
- Chain dependencies: `current_user = Depends(get_current_user)` which itself depends on `get_db`
- Use `yield` dependencies for cleanup (database session, temp files): `yield db; db.close()`
- Scope dependencies per-request by default; cache with `use_cache=True` in request scope

### Async Patterns
- Use `async def` for route handlers that perform I/O (database, HTTP, file)
- Use `def` (sync) for CPU-bound handlers — FastAPI runs them in a thread pool
- Use async database drivers (asyncpg, aiosqlite) with async SQLAlchemy or Tortoise ORM
- Use `httpx.AsyncClient` for outbound HTTP calls, not `requests`
- Use `BackgroundTasks` for fire-and-forget operations (email, logging)

### Error Handling
- Raise `HTTPException(status_code=404, detail="User not found")` for HTTP errors
- Register custom exception handlers with `@app.exception_handler(CustomError)`
- Use consistent error response shape: `{ "detail": "message" }` or custom schema
- Validate all input via Pydantic schemas — invalid input automatically returns 422

### Anti-Patterns to Avoid
- Do not use sync database drivers with async handlers — it blocks the event loop
- Do not put business logic in route handlers — delegate to service layer
- Do not use global mutable state — use dependency injection for per-request state
- Do not skip response model definitions — they filter sensitive data and generate docs
- Do not use `requests` library — use `httpx` for both sync and async HTTP clients
