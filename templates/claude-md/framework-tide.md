## Tide Conventions

### Project Structure
- Entry point: `src/main.rs` with `#[async_std::main]` and `app.listen("0.0.0.0:8080")`
- Handlers: `src/handlers/{resource}.rs` with endpoint functions
- State: `src/state.rs` for shared application state struct
- Models: `src/models/` for domain types and DTOs
- Middleware: `src/middleware/` for custom middleware
- Routes: register in `main.rs` or a `src/routes.rs` module

### Application State
- Define state struct: `#[derive(Clone)] struct AppState { db: PgPool }`
- Create app with state: `let mut app = tide::with_state(AppState::new())`
- Access in handlers: `let state = req.state()` — returns a reference to shared state
- State must implement `Clone` and `Send + Sync + 'static`

### Route and Handler Patterns
- Define routes: `app.at("/api/users").get(list_users).post(create_user)`
- Nested routes: `app.at("/api/users/:id").get(get_user).put(update_user).delete(delete_user)`
- Handlers: `async fn list_users(req: Request<AppState>) -> tide::Result { ... }`
- Path params: `req.param("id")?.parse::<Uuid>()?`
- JSON body: `let body: CreateUser = req.body_json().await?`
- Respond: `Ok(Response::builder(200).body(Body::from_json(&data)?).build())`
- Or use `tide::Response::new(StatusCode::Ok)` with body methods

### Middleware
- Apply globally: `app.with(tide::log::LogMiddleware::new())`
- Custom middleware: implement `tide::Middleware<State>` trait
- Middleware has `handle` method receiving `Request<State>` and `Next` for chain
- Use middleware for auth, logging, CORS, rate limiting
- Route-specific middleware: use `app.at("/admin").with(admin_middleware).get(handler)`

### Error Handling
- Return `tide::Result` (alias for `Result<Response, tide::Error>`) from handlers
- Use `tide::Error::from_str(StatusCode, message)` for HTTP errors
- Use `?` operator — standard errors are converted to 500 responses by default
- Customize error responses by catching errors in middleware
- Use `anyhow` for internal error propagation with context

### Serialization
- Use `serde` with `Serialize`/`Deserialize` for all request/response types
- Body parsing: `req.body_json::<T>().await?` for JSON
- Response building: `Body::from_json(&data)?` or `Response::builder(200).body(json)`
- Form data: `req.body_form::<T>().await?`

### Anti-Patterns to Avoid
- Do not use `std::sync::Mutex` — use `async_std::sync::Mutex` or `RwLock` for async safety
- Do not block the async runtime with synchronous I/O — use async-std compatible libraries
- Do not forget error handling — bare `unwrap()` in handlers crashes on bad input
- Do not store per-request data in application state — use request extensions
- Do not skip middleware for cross-cutting concerns — duplicate logic across handlers is fragile
