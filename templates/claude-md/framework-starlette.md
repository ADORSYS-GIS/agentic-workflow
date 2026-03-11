## Starlette Conventions

### Project Structure
- Entry point: `app/main.py` with `Starlette(routes=[...])` application
- Routes: `app/routes/{resource}.py` with route handler functions
- Middleware: `app/middleware/` for custom ASGI middleware
- Services: `app/services/` for business logic
- Models: `app/models/` for database models
- Use `Mount` for sub-applications and route grouping

### Route Patterns
- Define routes as `Route('/path', endpoint=handler)` or use `@app.route('/path')`
- Use `Mount('/api', routes=[...])` to group related routes under a prefix
- Route parameters: `Route('/users/{user_id:int}', endpoint=get_user)`
- Type converters: `int`, `float`, `str`, `uuid`, `path` for route parameters
- Use `WebSocketRoute` for WebSocket endpoints

### Request and Response
- Access request data: `request.path_params`, `await request.json()`, `request.query_params`
- Return `JSONResponse(content, status_code=200)` for JSON APIs
- Use `HTMLResponse`, `PlainTextResponse`, `RedirectResponse` for other content types
- Use `StreamingResponse` for large payloads or server-sent events
- Set response headers: `JSONResponse(content, headers={'X-Custom': 'value'})`

### Middleware
- Add middleware in app construction: `Starlette(middleware=[Middleware(CORSMiddleware, ...)])`
- Custom middleware: implement as ASGI functions or use `BaseHTTPMiddleware`
- Prefer pure ASGI middleware over `BaseHTTPMiddleware` for performance
- Common middleware: `CORSMiddleware`, `TrustedHostMiddleware`, `GZipMiddleware`

### Async Patterns
- All route handlers should be `async def` — Starlette is async-first
- Use `asyncio` primitives for concurrent operations
- Use async database libraries (databases, asyncpg, aiosqlite)
- Use `httpx.AsyncClient` for outbound HTTP requests
- Background tasks: pass a `BackgroundTask` to response constructors

### Error Handling
- Use `HTTPException(status_code=404, detail='Not found')` for HTTP errors
- Register exception handlers: `Starlette(exception_handlers={404: not_found_handler})`
- Implement custom exception classes for domain errors
- Always return structured JSON error responses for API endpoints

### Anti-Patterns to Avoid
- Do not use synchronous I/O in async handlers — it blocks the event loop
- Do not rely on global state — use Starlette's `State` on the app instance
- Do not skip input validation — Starlette does not validate automatically (use Pydantic manually)
- Do not use `BaseHTTPMiddleware` in performance-critical paths — use raw ASGI middleware
