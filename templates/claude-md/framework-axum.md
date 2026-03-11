## Axum Conventions

### Project Structure
- Entry point: `src/main.rs` with `tokio::main` async runtime and `axum::Router`
- Handlers: `src/handlers/{resource}.rs` with async handler functions
- Services: `src/services/{resource}.rs` for business logic
- Models: `src/models/` for domain types and DTOs (with `serde::Serialize`/`Deserialize`)
- State: `src/state.rs` for shared application state (`AppState`)
- Error: `src/error.rs` for custom error types implementing `IntoResponse`
- Routes: `src/routes.rs` composing the router from sub-routers

### Route and Handler Patterns
- Build routers: `Router::new().route("/users", get(list_users).post(create_user))`
- Nest routers: `Router::new().nest("/api/v1", api_routes())`
- Handlers are async functions with extractors as parameters
- Extractors: `Path(id): Path<Uuid>`, `Json(body): Json<CreateUser>`, `Query(params): Query<ListParams>`
- Return `impl IntoResponse` or specific types: `Json<T>`, `(StatusCode, Json<T>)`

### State and Dependency Injection
- Define `AppState` struct with `Arc`: `#[derive(Clone)] struct AppState { db: PgPool, config: Arc<Config> }`
- Pass state to router: `Router::new().with_state(state)` and extract with `State(state): State<AppState>`
- Use `FromRef` derive for substates: extractors can pull specific fields from `AppState`
- Prefer `Extension<T>` only for middleware-injected per-request values

### Extractors
- Axum extracts handler parameters in order; the last extractor can consume the request body
- Body extractors (`Json`, `Form`, `Bytes`) must be the last parameter
- Custom extractors: implement `FromRequestParts<S>` (non-body) or `FromRequest<S>` (body)
- Rejection handling: implement `From<JsonRejection>` on your error type for custom error responses
- Use `Option<T>` for optional extractors; `Result<T, E>` to handle extraction failures manually

### Error Handling
- Define `AppError` enum implementing `IntoResponse` for all handler errors
- Use `thiserror` for error definitions; map to `(StatusCode, Json<ErrorBody>)` in `IntoResponse`
- Use the `?` operator in handlers by returning `Result<impl IntoResponse, AppError>`
- Log errors in the `IntoResponse` implementation; return sanitized messages to clients

### Middleware
- Use `tower` middleware: `ServiceBuilder::new().layer(TraceLayer::new(...)).layer(CorsLayer::new(...))`
- Apply per-route: `Router::new().route("/", get(handler)).layer(middleware)`
- Use `axum::middleware::from_fn` for custom async middleware functions
- Use `tower-http` crate for common middleware: CORS, compression, request tracing, timeout

### Anti-Patterns to Avoid
- Do not use `unwrap()` in handlers — return `Result` with a proper error type
- Do not hold `MutexGuard` across `.await` points — use `tokio::sync::Mutex` if needed
- Do not block the async runtime — use `tokio::task::spawn_blocking` for CPU-intensive work
- Do not forget to add `#[derive(Deserialize)]` on request types and `#[derive(Serialize)]` on response types
- Do not create a new database pool per request — share via `AppState`
