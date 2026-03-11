## Rocket Conventions

### Project Structure
- Entry point: `src/main.rs` with `#[launch] fn rocket() -> _ { rocket::build().mount(...) }`
- Handlers: `src/handlers/{resource}.rs` with `#[get]`, `#[post]` annotated functions
- Models: `src/models/` for domain types and form/JSON structures
- Fairings: `src/fairings/` for request/response lifecycle hooks (middleware)
- Guards: `src/guards/` for request guards (auth, validation)
- State: managed state via `rocket.manage(state)` and `&State<T>` extraction
- Config: `Rocket.toml` for environment-based configuration

### Route and Handler Patterns
- Annotate handlers: `#[get("/users/<id>")]`, `#[post("/users", data = "<body>")]`
- Mount routes: `rocket::build().mount("/api", routes![list_users, get_user, create_user])`
- Path params: `fn get_user(id: i32)` — types validated automatically from the path
- JSON body: `fn create_user(body: Json<CreateUser>)` — auto-deserialized and validated
- Query params: `fn list_users(page: Option<u32>, limit: Option<u32>)` — optional by default

### Request Guards
- Request guards validate and extract data before the handler runs
- Built-in guards: `&State<T>`, `Json<T>`, `Form<T>`, `&CookieJar`, `&ContentType`
- Custom guards: implement `FromRequest` for auth tokens, user context, rate limiting
- Guards can fail with typed errors — Rocket forwards to the next matching route or returns error
- Use `#[guard]` attribute for compile-time route parameter validation

### State Management
- Application state: `rocket.manage(AppState::new())` — inject with `state: &State<AppState>`
- State is shared across all handlers (like a singleton)
- Use `Arc<Mutex<T>>` or `tokio::sync::RwLock<T>` for mutable shared state
- Database: use `rocket_db_pools` with `#[database("db_name")]` for connection pool management

### Fairings (Middleware)
- Fairings attach to lifecycle events: `on_ignite`, `on_liftoff`, `on_request`, `on_response`
- Use `AdHoc::on_request` for simple middleware: `AdHoc::on_request("Logger", |req, _| { ... })`
- Custom fairings: implement `Fairing` trait for complex middleware
- CORS: use `rocket_cors` crate or a custom fairing
- Fairings run in registration order

### Error Handling
- Use catchers for HTTP error pages: `#[catch(404)] fn not_found() -> Json<ErrorResponse>`
- Register catchers: `rocket::build().register("/", catchers![not_found, internal_error])`
- Return `Result<Json<T>, Status>` from handlers for explicit error responses
- Custom error types: implement `Responder` for domain-specific error responses

### Anti-Patterns to Avoid
- Do not use `unwrap()` in handlers — return `Result` or `Option` for Rocket's error handling
- Do not skip `Rocket.toml` configuration — it provides environment-based settings
- Do not use blocking I/O in async handlers — Rocket v0.5+ uses async/tokio
- Do not forget to register routes with `routes![]` macro — unregistered handlers are silently ignored
- Do not store per-request data in managed state — use request-local state or guards
