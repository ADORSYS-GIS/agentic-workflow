## Echo Conventions

### Project Structure
- Entry point: `cmd/server/main.go` with `e := echo.New()` and `e.Start(":8080")`
- Handlers: `internal/handler/{resource}.go` with handler functions
- Services: `internal/service/{resource}.go` for business logic
- Repositories: `internal/repository/{resource}.go` for data access
- Models: `internal/model/` for domain types and request/response structs
- Middleware: `internal/middleware/` for custom middleware
- Routes: `internal/router/router.go` for centralized route registration

### Route and Handler Patterns
- Group routes: `v1 := e.Group("/api/v1")` with grouped middleware
- Handlers: `func (h *UserHandler) GetUser(c echo.Context) error`
- Path params: `c.Param("id")`; query: `c.QueryParam("page")`; body: `c.Bind(&req)`
- Always return errors from handlers — Echo's error handler processes them
- Response: `c.JSON(http.StatusOK, data)` or `c.NoContent(http.StatusNoContent)`

### Middleware
- Built-in middleware: `e.Use(middleware.Logger(), middleware.Recover(), middleware.CORS())`
- Group middleware: `admin := v1.Group("/admin", middleware.KeyAuth(...))`
- Custom middleware: `func CustomMiddleware(next echo.HandlerFunc) echo.HandlerFunc`
- Use `middleware.BodyLimit("2M")` to prevent oversized request bodies
- `middleware.RateLimiter()` for rate limiting; `middleware.Secure()` for security headers

### Binding and Validation
- Use `c.Bind(&request)` for automatic binding from JSON, form, and query parameters
- Struct tags: `json:"name" query:"name" validate:"required,min=3"`
- Register a custom validator: `e.Validator = &CustomValidator{validator: validator.New()}`
- Binding checks `Content-Type` header and deserializes accordingly
- Handle binding errors by returning `echo.NewHTTPError(http.StatusBadRequest, err.Error())`

### Error Handling
- Echo has a centralized error handler: `e.HTTPErrorHandler = customErrorHandler`
- Return `echo.NewHTTPError(status, message)` from handlers for HTTP errors
- Return custom error types that implement `error` for domain-specific errors
- Custom error handler: inspect error type and return consistent JSON response
- Echo's recovery middleware catches panics and converts them to 500 responses

### Performance
- Echo uses a radix tree router — one of the fastest Go HTTP routers
- Use `c.Stream()` for large response bodies
- Use `middleware.GzipWithConfig()` for response compression
- Connection pooling for database and HTTP clients at the application level

### Anti-Patterns to Avoid
- Do not ignore handler return errors — they drive the error handling pipeline
- Do not put business logic in handlers — delegate to services
- Do not use `c.String()` for JSON APIs — use `c.JSON()` with typed structs
- Do not create Echo instances per-request — one instance for the application lifetime
- Do not skip input validation — bind operations do not validate by default
