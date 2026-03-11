## Express Conventions

### Project Structure
- Entry point: `src/app.ts` (Express app setup) and `src/server.ts` (HTTP server startup)
- Routes: `src/routes/{resource}.routes.ts` — register on the app with a prefix
- Controllers: `src/controllers/{resource}.controller.ts` — handle request/response
- Services: `src/services/{resource}.service.ts` — business logic, no HTTP knowledge
- Middleware: `src/middleware/` (auth, validation, error handling, logging)
- Validators: `src/validators/` using Zod, Joi, or express-validator schemas

### Middleware Patterns
- Apply middleware in order: logging, CORS, body parsing, auth, rate limiting, routes, error handler
- Global error handler must be registered last with four parameters: `(err, req, res, next)`
- Auth middleware: validate token and attach user to `req.user`; call `next()` or return 401
- Use `express.json()` with a body size limit: `express.json({ limit: '1mb' })`
- Always call `next()` in middleware or send a response — never leave requests hanging

### Route and Controller Patterns
- Use `Router()` for modular route files; mount with `app.use('/api/v1/users', userRoutes)`
- Controllers are thin: parse input, call service, format response
- Always validate request body, params, and query before processing
- Return consistent response shapes: `{ data, meta }` for success, `{ error: { code, message } }` for errors
- Use proper HTTP status codes: 201 for creation, 204 for deletion, 400 for validation, 404 for not found

### Error Handling
- Wrap async route handlers to catch rejected promises: use `express-async-errors` or a wrapper function
- Never let unhandled promise rejections crash the server
- Define custom `AppError` class with `statusCode` and `code` properties
- Central error handler logs errors and sends sanitized responses (no stack traces in production)
- Handle 404 with a catch-all middleware after all routes

### Security
- Use `helmet` middleware for secure HTTP headers
- Use `cors` middleware with an explicit origin allowlist
- Rate limit with `express-rate-limit` on auth endpoints and public APIs
- Sanitize user input; never interpolate request values into database queries
- Use `hpp` to protect against HTTP parameter pollution

### Anti-Patterns to Avoid
- Do not put business logic in route handlers or middleware
- Do not use `app.use('*')` for catch-all — it interferes with routing
- Do not send multiple responses in a single request (check `res.headersSent`)
- Do not store state in module-level variables — the server is long-running and shared
