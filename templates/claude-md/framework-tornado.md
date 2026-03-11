## Tornado Conventions

### Project Structure
- Entry point: `app/main.py` with `tornado.web.Application` and `IOLoop.current().start()`
- Handlers: `app/handlers/{resource}.py` with `RequestHandler` subclasses
- Models: `app/models/` for database models
- Services: `app/services/` for business logic
- Templates: `app/templates/` for HTML templates
- Static files: `app/static/`
- Configuration: `app/settings.py` or command-line options with `tornado.options`

### Handler Patterns
- Subclass `tornado.web.RequestHandler` for HTTP endpoints
- Override `get()`, `post()`, `put()`, `delete()` for HTTP methods
- Use `async def` for handlers that perform I/O
- Access parameters: `self.get_argument("name")`, `self.path_args`, `self.request.body`
- Write responses: `self.write(dict)` auto-serializes to JSON; `self.render("template.html")`

### Application Setup
- Define routes as a list of tuples: `[(r"/users", UserHandler), (r"/users/(\d+)", UserDetailHandler)]`
- Pass settings dict: `Application(routes, debug=False, cookie_secret="...", xsrf_cookies=True)`
- Use `URLSpec` for named routes: `URLSpec(r"/user/(\d+)", UserHandler, name="user_detail")`
- Serve static files via `static_path` setting; access with `self.static_url("file.js")`

### Async Patterns
- Use native `async`/`await` for all I/O operations
- Use `tornado.httpclient.AsyncHTTPClient` for outbound HTTP requests
- Use async database drivers (motor for MongoDB, aiopg for PostgreSQL)
- Use `tornado.gen.multi()` for concurrent async operations
- Use `IOLoop.current().spawn_callback()` for fire-and-forget tasks

### Security
- Enable XSRF protection: set `xsrf_cookies=True` in application settings
- Use `self.current_user` with `get_current_user()` override for authentication
- Use `@tornado.web.authenticated` decorator for protected handlers
- Set `cookie_secret` for secure cookies; use `self.set_secure_cookie()` / `self.get_secure_cookie()`
- Escape template output by default — use `{% raw %}` only when explicitly needed

### Anti-Patterns to Avoid
- Do not use synchronous I/O in handlers — it blocks the entire event loop
- Do not call `self.finish()` and then write more data — the response is already sent
- Do not use `threading` for concurrency — use Tornado's async primitives
- Do not skip error handling in `write_error()` override — provide consistent error responses
- Do not use Tornado's `@gen.coroutine` in new code — use native `async`/`await`
