## Hono Conventions

### Project Structure
- Entry point: `src/index.ts` creating the Hono app
- Routes: `src/routes/{resource}.ts` using `Hono` sub-apps
- Middleware: `src/middleware/` for custom middleware
- Services: `src/services/` for business logic
- Types: `src/types/` for shared type definitions
- Mount sub-apps: `app.route('/api/users', userRoutes)`

### Route Patterns
- Create modular route files: `const app = new Hono()` per resource, export and mount in main app
- Use method chaining: `app.get('/users', handler).post('/users', handler)`
- Type-safe route parameters with generics: `app.get('/users/:id', (c) => ...)`
- Group related routes with `app.basePath('/api/v1')`
- Use `app.on(['GET', 'POST'], '/path', handler)` for multi-method handlers

### Middleware
- Use `app.use('*', middleware)` for global middleware
- Use `app.use('/api/*', middleware)` for path-scoped middleware
- Built-in middleware: `cors()`, `logger()`, `secureHeaders()`, `compress()`
- Custom middleware: `async (c, next) => { ... await next(); ... }`
- Middleware order matters — declare from outer (global) to inner (route-specific)

### Context and Validation
- Access request data via context: `c.req.json()`, `c.req.query()`, `c.req.param()`
- Use Zod with `@hono/zod-validator` for type-safe request validation
- Validate at the route level: `app.post('/users', zValidator('json', schema), handler)`
- Return responses: `c.json({ data })`, `c.text('ok')`, `c.html('<p>hi</p>')`
- Set headers and status: `c.status(201)`, `c.header('X-Custom', 'value')`

### Environment Variables and Bindings
- Access env via `c.env` — typed with Hono generics: `new Hono<{ Bindings: Env }>()`
- For Cloudflare Workers: access KV, D1, R2 via `c.env`
- For Node.js: use `process.env` or `@hono/node-server` adapter
- Define environment types in a shared type file for consistency

### Performance
- Hono uses a trie-based router — route registration order does not affect performance
- Use streaming responses with `c.stream()` for large payloads
- Use `c.executionCtx.waitUntil()` for background tasks on edge platforms
- Avoid middleware on static asset routes

### Anti-Patterns to Avoid
- Do not use Express-style `req`/`res` — use Hono's context `c`
- Do not forget to `await next()` in middleware — it breaks the chain
- Do not mutate `c.req` — use `c.set()` and `c.get()` for passing data through middleware
- Do not assume Node.js APIs are available — Hono is runtime-agnostic (Web Standards)
