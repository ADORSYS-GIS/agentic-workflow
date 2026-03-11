## Actix Web Conventions

### Project Structure
- Entry point: `src/main.rs` with `#[actix_web::main]` async main and `HttpServer::new`
- Handlers: `src/handlers/{resource}.rs` with handler functions
- Services: `src/services/{resource}.rs` for business logic
- Models: `src/models/` for domain types and DTOs
- State: `src/state.rs` for shared `AppState` wrapped in `web::Data<T>`
- Config: `src/config.rs` for application configuration
- Routes: `src/routes.rs` for `web::ServiceConfig` functions

### Route and Handler Patterns
- Configure routes: `web::scope("/api").service(web::resource("/users").route(web::get().to(list_users)))`
- Or use macros: `#[get("/users/{id}")]`, `#[post("/users")]` on handler functions
- Handlers: `async fn get_user(path: web::Path<Uuid>, state: web::Data<AppState>) -> impl Responder`
- Extractors: `web::Path<T>`, `web::Json<T>`, `web::Query<T>`, `web::Data<T>`
- Response: `HttpResponse::Ok().json(data)` or return `impl Responder`

### Application State
- Define state: `struct AppState { db: PgPool, config: AppConfig }`
- Share state: `App::new().app_data(web::Data::new(state))` — wrapped in `Arc` internally
- Extract in handlers: `state: web::Data<AppState>`
- Per-request data: use `HttpRequest::extensions()` for middleware-injected values
- Configure at scope level: `web::scope("/api").app_data(web::Data::new(service))`

### Extractors and Validation
- Body extractors: `web::Json<T>` auto-deserializes and validates with serde
- Configure extractor limits: `web::JsonConfig::default().limit(4096).error_handler(custom_handler)`
- Custom extractors: implement `FromRequest` trait for request-scoped dependencies
- Use `actix-web-validator` or manual validation after extraction
- Extraction errors: configure `JsonConfig::error_handler` for custom error responses

### Error Handling
- Implement `ResponseError` trait on custom error types
- `ResponseError` provides `error_response()` returning `HttpResponse` and `status_code()`
- Use `thiserror` for error enum definitions
- Map service errors to HTTP responses in the `ResponseError` implementation
- Use `?` operator in handlers — Actix auto-converts errors implementing `ResponseError`

### Middleware
- Apply via `App::new().wrap(middleware)` or `web::scope("/api").wrap(middleware)`
- Use `actix-web::middleware::Logger` for request logging
- Use `actix-cors` for CORS configuration
- Custom middleware: implement `Transform` and `Service` traits or use `from_fn`
- Guard functions: `web::guard::Header("content-type", "application/json")` for route matching

### Anti-Patterns to Avoid
- Do not use `web::block()` for async operations — it is for blocking (CPU/sync I/O) code only
- Do not share `Mutex<T>` across handlers — use `web::Data<Mutex<T>>` or async-safe alternatives
- Do not return `String` for JSON APIs — use `HttpResponse::Ok().json(data)` with typed responses
- Do not forget to configure extractor error handlers — default errors expose internal details
- Do not create database pools inside handlers — share via `web::Data<T>`
