## Sanic Conventions

### Project Structure
- Entry point: `app/server.py` with `Sanic("AppName")` instance
- Blueprints: `app/blueprints/{feature}.py` for modular route groups
- Models: `app/models/` for ORM models (Tortoise ORM recommended for async)
- Services: `app/services/` for business logic
- Middleware: `app/middleware/` for custom request/response middleware
- Configuration: `app/config.py` or `config/` directory with environment-based files

### Route and Blueprint Patterns
- Use blueprints for every feature: `bp = Blueprint("users", url_prefix="/users")`
- Register blueprints: `app.blueprint(users_bp)`
- Route decorators: `@bp.get("/")`, `@bp.post("/")`, `@bp.put("/<id:int>")`
- Type-annotated path parameters: `<user_id:int>`, `<slug:str>`, `<id:uuid>`
- Group blueprints: `BlueprintGroup(users_bp, posts_bp, url_prefix="/api/v1")`

### Async Patterns
- All handlers must be `async def` — Sanic is async-only
- Use async database drivers (Tortoise ORM, asyncpg, databases)
- Use `httpx.AsyncClient` for outbound HTTP calls
- Background tasks: `app.add_task(background_function())` for long-running work
- Use `app.ctx` for application-wide shared state (database pools, caches)

### Request and Response
- Access data: `request.json`, `request.args`, `request.form`, `request.files`
- Return responses: `json({"data": data})`, `text("ok")`, `html("<p>hi</p>")`
- Streaming: `await response.send(chunk)` with `stream()` decorator
- File responses: `await file("path/to/file")` or `await file_stream("path")`
- Custom headers: `json(data, headers={"X-Custom": "value"})`

### Middleware
- Request middleware: `@app.on_request` — runs before handler
- Response middleware: `@app.on_response` — runs after handler
- Blueprint-scoped middleware for feature-specific processing
- Use listeners for lifecycle events: `@app.before_server_start`, `@app.after_server_stop`

### Error Handling
- Use `SanicException(message, status_code=400)` for HTTP errors
- Register error handlers: `@app.exception(NotFound)` for specific exceptions
- Custom fallback handler: `@app.exception(Exception)` for unhandled errors
- Return consistent JSON error responses

### Anti-Patterns to Avoid
- Do not use synchronous I/O (requests, psycopg2) — it blocks the async loop
- Do not use `app.run()` in production — use `sanic` CLI or ASGI server
- Do not store per-request state on `app.ctx` — use `request.ctx` instead
- Do not skip signal handlers for graceful shutdown
