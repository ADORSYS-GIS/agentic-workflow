## Fastify Conventions

### Project Structure
- Entry point: `src/app.ts` (Fastify instance) and `src/server.ts` (start/listen)
- Routes: `src/routes/{resource}/` with `index.ts` defining route handlers
- Plugins: `src/plugins/` for reusable functionality (auth, database, caching)
- Schemas: `src/schemas/` for JSON Schema definitions used in validation and serialization
- Services: `src/services/` for business logic

### Plugin Architecture
- Encapsulate features as Fastify plugins using `fastify-plugin` for shared context
- Register plugins with `fastify.register()` with optional prefix for route scoping
- Use `fastify.decorate()` to add shared utilities (db client, auth helpers) to the instance
- Plugins have access to encapsulation — child plugins inherit parent context but not vice versa
- Load order matters: register database plugins before route plugins that depend on them

### Route Patterns
- Define routes using the shorthand methods: `fastify.get()`, `fastify.post()`, etc.
- Use route schemas for input validation and output serialization (JSON Schema or Typebox)
- Schema-based validation is faster than middleware-based — always define `schema.body`, `schema.params`, `schema.querystring`
- Use `schema.response` to control and speed up serialization (fast-json-stringify)
- Group related routes in a plugin with a shared prefix

### Validation and Serialization
- Use `@sinclair/typebox` for type-safe JSON Schema definitions that infer TypeScript types
- Define request and response schemas for every route
- Use `ajv` (built-in) for validation; configure with `removeAdditional: true` and `coerceTypes: false`
- Serialization schemas improve response throughput by 2-3x — always define them for production APIs

### Error Handling
- Use `fastify.setErrorHandler()` for centralized error handling
- Throw `fastify.httpErrors` helpers for standard HTTP errors (`.notFound()`, `.badRequest()`)
- Use `@fastify/sensible` for standardized error creation
- Custom errors should include `statusCode` for proper HTTP response codes
- Never let validation errors expose internal schema details in production

### Anti-Patterns to Avoid
- Do not use Express middleware directly — use `@fastify/express` only as a migration bridge
- Do not use `reply.send()` and return a value in the same handler — pick one
- Do not mutate `request.body` — Fastify freezes it after validation
- Do not skip schema definitions — they are core to Fastify's performance model
- Do not block the event loop in handlers — offload CPU work to worker threads
