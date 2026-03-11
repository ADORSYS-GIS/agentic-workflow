## Fiber Conventions

### Project Structure
- Entry point: `cmd/server/main.go` with `app := fiber.New()` and `app.Listen(":3000")`
- Handlers: `internal/handler/{resource}.go` for request handlers
- Services: `internal/service/{resource}.go` for business logic
- Models: `internal/model/` for domain types and DTOs
- Middleware: `internal/middleware/` for custom middleware
- Config: `internal/config/` for app configuration and environment loading
- Routes: `internal/router/router.go` for route registration

### Route and Handler Patterns
- Group routes: `api := app.Group("/api/v1")`
- Define handlers: `func (h *UserHandler) GetUser(c *fiber.Ctx) error`
- Path params: `c.Params("id")`; query: `c.Query("page")`; body: `c.BodyParser(&req)`
- Response: `c.JSON(data)`, `c.Status(201).JSON(data)`, `c.SendString("ok")`
- Use `c.Locals("key", value)` for passing data between middleware and handlers

### Middleware
- Built-in: `app.Use(logger.New(), recover.New(), cors.New())`
- Rate limiting: `limiter.New(limiter.Config{Max: 100, Expiration: 1 * time.Minute})`
- Custom middleware: `func AuthMiddleware(c *fiber.Ctx) error { ... return c.Next() }`
- Group-level middleware: `admin.Use(middleware.AdminOnly())`
- Use `compress.New()` for gzip/brotli response compression

### Request Parsing and Validation
- Body parsing: `c.BodyParser(&req)` for JSON, XML, form data
- Use struct tags: `json:"name" validate:"required,min=3"`
- Integrate `go-playground/validator` for struct validation after parsing
- Access headers: `c.Get("Authorization")`; cookies: `c.Cookies("session")`
- File upload: `file, err := c.FormFile("avatar")`

### Important: Fasthttp Differences
- Fiber is built on fasthttp, NOT net/http — handler context values do NOT persist after return
- Never store `*fiber.Ctx` in goroutines or pass it to background functions
- Copy values from `c` before spawning goroutines: `id := c.Params("id")` then use `id` in goroutine
- Request body and headers are reused across requests — copy if storing
- Use `c.Context()` carefully — it returns a `fasthttp.RequestCtx`, not `context.Context`

### Error Handling
- Return errors from handlers: `return fiber.NewError(404, "user not found")`
- Custom error handler: `app := fiber.New(fiber.Config{ErrorHandler: customHandler})`
- Use `fiber.ErrBadRequest`, `fiber.ErrNotFound` for standard HTTP errors
- Log errors with request context (path, method, request ID)

### Anti-Patterns to Avoid
- Do not pass `*fiber.Ctx` to goroutines — copy needed values first (fasthttp limitation)
- Do not use net/http middleware directly — they are not compatible with Fiber
- Do not put business logic in handlers — delegate to services
- Do not assume standard Go HTTP library conventions apply — Fiber/fasthttp has different semantics
- Do not skip the `Recover` middleware — unhandled panics will crash the server
