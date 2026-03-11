## Warp Conventions

### Project Structure
- Entry point: `src/main.rs` with `#[tokio::main]` and `warp::serve(routes).run(addr)`
- Filters: `src/filters/{resource}.rs` composing route filters
- Handlers: `src/handlers/{resource}.rs` with async handler functions
- Models: `src/models/` for domain types and DTOs
- State: `src/state.rs` for shared application state
- Error: `src/error.rs` for custom rejection and error handling

### Filter Composition
- Warp uses composable filters instead of traditional routes
- Build filters: `warp::path("users").and(warp::get()).and_then(list_users)`
- Combine with `.or()`: `let routes = users_list.or(users_create).or(users_get)`
- Chain with `.and()`: `warp::path("users").and(warp::body::json()).and_then(create_user)`
- Filters extract data and pass to handlers as function parameters

### Handler Patterns
- Handlers are async functions returning `Result<impl Reply, Rejection>`
- JSON response: `Ok(warp::reply::json(&data))` or `Ok(warp::reply::with_status(json, StatusCode::CREATED))`
- Handlers receive extracted data as parameters: `async fn get_user(id: Uuid, db: DbPool) -> Result<impl Reply, Rejection>`
- Keep handlers thin — delegate business logic to service functions

### State and Dependency Injection
- Share state via filter: `fn with_db(db: DbPool) -> impl Filter<Extract = (DbPool,)> + Clone`
- Implementation: `warp::any().map(move || db.clone())`
- Compose state into routes: `warp::path("users").and(with_db(pool)).and_then(list_users)`
- State is cloned per-request — use `Arc` for expensive resources

### Rejection and Error Handling
- Warp uses Rejections for error handling — custom rejections implement `warp::reject::Reject`
- Recover from rejections: `routes.recover(handle_rejection)`
- In `handle_rejection`: match on rejection types and return appropriate HTTP responses
- Define custom rejection types: `#[derive(Debug)] struct NotFound;` + `impl warp::reject::Reject for NotFound {}`
- Map rejections to JSON errors with proper status codes

### Middleware (Filters)
- Logging: `warp::log("api")` filter or use `tracing` with `warp::trace`
- CORS: `warp::cors().allow_origin("https://example.com").allow_methods(vec!["GET", "POST"])`
- Apply to routes: `routes.with(cors).with(warp::log("api"))`
- Custom middleware: create filters that inspect/modify requests before passing through

### Anti-Patterns to Avoid
- Do not create deeply nested filter chains — extract into named functions for readability
- Do not use `unwrap()` in handlers — return `Rejection` for errors
- Do not forget `.recover()` — unhandled rejections return unhelpful default error responses
- Do not block the async runtime — use `tokio::task::spawn_blocking` for CPU work
- Do not duplicate filter composition — extract shared filters (auth, state) into reusable functions
