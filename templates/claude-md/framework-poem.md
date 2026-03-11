## Poem Conventions

### Project Structure
- Entry point: `src/main.rs` with `#[tokio::main]` and `Server::new(TcpListener::bind(addr)).run(app)`
- Handlers: `src/handlers/{resource}.rs` with handler functions
- API definitions: `src/api/{resource}.rs` using Poem's OpenAPI derive macros
- Models: `src/models/` for domain types and request/response DTOs
- State: `src/state.rs` for shared data passed to handlers
- Middleware: `src/middleware/` for custom middleware

### Route Patterns
- Use `Route::new().at("/users", get(list_users).post(create_user))`
- Nested routes: `Route::new().nest("/api/v1", api_routes())`
- Path params: define in route `.at("/users/:id")`, extract with `Path<(Uuid,)>`
- Poem supports both standalone and OpenAPI-driven routing

### OpenAPI Integration
- Use `poem-openapi` for type-safe API definitions with auto-generated documentation
- Define API structs: `struct UserApi;` with `#[OpenApi]` impl blocks
- Tag operations: `#[oai(path = "/users", method = "get", tag = "Users")]`
- Request types: use `Json<T>`, `Query<T>`, `Path<T>` from `poem-openapi`
- Response types: define enums with `#[derive(ApiResponse)]` for typed HTTP responses
- Serve docs: `OpenApiService::new(api, "Title", "1.0").swagger_ui()`

### Extractors
- Path: `Path<(String,)>` or `Path<UserId>` with custom deserialize
- Body: `Json<CreateUser>` auto-validates with serde
- Query: `Query<ListParams>` for URL query parameters
- Headers: `Header<Authorization>` for typed header extraction
- Data: `Data<&AppState>` for shared application state
- Custom extractors: implement `FromRequest` trait

### Error Handling
- Use `poem::Result<T>` for handler return types
- Return `poem::Error::from_status(StatusCode::NOT_FOUND)` for HTTP errors
- Custom errors: implement `Into<poem::Error>` or `ResponseError` for domain errors
- With OpenAPI: use `#[derive(ApiResponse)]` enums for type-safe error responses
- Middleware can intercept and transform errors before they reach the client

### Middleware
- Use `EndpointExt` methods: `route.with(middleware)` or `route.around(middleware_fn)`
- Built-in: `Tracing`, `Cors`, `Compression`, `CatchPanic`
- Custom middleware: implement `Middleware<E>` trait or use `.around()` closure
- Tower compatibility: use `poem::middleware::TowerCompatExt` to reuse tower middleware

### Anti-Patterns to Avoid
- Do not skip OpenAPI annotations when using poem-openapi — incomplete docs mislead consumers
- Do not block the tokio runtime — use `spawn_blocking` for CPU-intensive work
- Do not use `unwrap()` in handlers — return proper error types
- Do not forget to add `#[derive(Deserialize)]` on extractable types
- Do not create state objects per-request — share via `AddData` middleware or route data
