## Vert.x Conventions

### Project Structure
- Entry point: `MainVerticle.java` deploying other verticles
- Verticles: `com.company.app.verticle/` — one verticle per concern (HTTP, DB, worker)
- Handlers: `com.company.app.handler/` for HTTP request handlers
- Services: `com.company.app.service/` for business logic accessed via event bus or direct injection
- Configuration: `src/main/resources/config.json` or environment-based YAML

### Verticle Patterns
- Use `AbstractVerticle` for standard verticles; override `start()` with `Promise<Void>` for async init
- HTTP verticle: create `Router` and `HttpServer` in `start()`
- Worker verticles: for blocking operations (JDBC, file I/O) deployed with `DeploymentOptions().setWorker(true)`
- Scale verticles with instances: `vertx.deployVerticle(MainVerticle.class, new DeploymentOptions().setInstances(4))`
- Keep verticles small and focused — one responsibility per verticle

### Routing and Handlers
- Use `Router` from `vertx-web`: `Router.router(vertx)`
- Define routes: `router.get("/api/users/:id").handler(this::getUser)`
- Use `BodyHandler.create()` for JSON parsing; `CorsHandler` for CORS
- Chain handlers: validation -> auth -> business logic -> response
- Always end the response: `ctx.response().end(json.encode())` or `ctx.json(object)`

### Event Bus
- Use the event bus for inter-verticle communication: `vertx.eventBus().send("address", message)`
- Define message codecs for custom types
- Use request/reply pattern: `eventBus.request("address", msg, reply -> {...})`
- Prefer event bus over shared state for verticle communication
- Use `@ProxyGen` service proxies for type-safe event bus communication

### Async and Reactive
- Never block the event loop — all I/O must be async
- Use `Future<T>` composition: `.compose()`, `.map()`, `.recover()`
- Use `vertx-jdbc-client` (async) or reactive clients (vertx-pg-client) for database access
- Use `CompositeFuture.all()` for parallel async operations
- Worker thread pool: use `vertx.executeBlocking()` for unavoidable blocking operations

### Anti-Patterns to Avoid
- Never call blocking APIs (JDBC, `Thread.sleep()`, `synchronized`) on event loop threads
- Do not share mutable state between verticles — use the event bus or shared data structures
- Do not deploy a single monolithic verticle — decompose by responsibility
- Do not use `vertx.executeBlocking()` as a default — use native async clients first
- Do not ignore `Future` failures — always handle errors with `.onFailure()` or `.recover()`
