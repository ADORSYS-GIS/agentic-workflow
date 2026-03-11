## Gin Conventions

### Project Structure
- Entry point: `cmd/server/main.go` with router setup and `router.Run()`
- Handlers: `internal/handler/{resource}.go` for HTTP handlers
- Services: `internal/service/{resource}.go` for business logic
- Repositories: `internal/repository/{resource}.go` for data access
- Models: `internal/model/` for domain types and DTOs
- Middleware: `internal/middleware/` for auth, logging, CORS
- Routes: `internal/router/router.go` centralizing route registration

### Route and Handler Patterns
- Group routes: `v1 := router.Group("/api/v1")` then `v1.GET("/users", handler.ListUsers)`
- Handlers receive `*gin.Context` — extract input, call service, write response
- Path parameters: `c.Param("id")`; query: `c.Query("page")`; body: `c.ShouldBindJSON(&req)`
- Always check binding errors: `if err := c.ShouldBindJSON(&req); err != nil { c.JSON(400, ...) }`
- Return consistent response shapes: `c.JSON(http.StatusOK, gin.H{"data": result})`

### Middleware
- Global middleware: `router.Use(gin.Logger(), gin.Recovery(), middleware.CORS())`
- Group middleware: `authorized := v1.Group("/", middleware.AuthRequired())`
- Custom middleware signature: `func AuthRequired() gin.HandlerFunc { return func(c *gin.Context) { ... c.Next() } }`
- Use `c.Set("userID", id)` and `c.Get("userID")` to pass data through middleware chain
- Call `c.Abort()` to stop the middleware chain on auth failure

### Validation
- Use struct tags with `binding:"required,email"` for validation via `go-playground/validator`
- Define request structs with `json` and `binding` tags
- Custom validators: register with `binding.Validator.Engine().(*validator.Validate).RegisterValidation()`
- Return field-level validation errors in the response

### Error Handling
- Define a custom error response type: `type ErrorResponse struct { Code string; Message string }`
- Use middleware for panic recovery (built-in `gin.Recovery()`)
- Centralize error formatting — do not format errors in every handler
- Log errors with context (request ID, user ID, path)

### Anti-Patterns to Avoid
- Do not put business logic in handlers — keep them thin; delegate to services
- Do not use `c.JSON` after `c.Abort` — `Abort` does not stop execution; return explicitly
- Do not use `gin.H{}` for complex response shapes — define typed response structs
- Do not store database connections in `gin.Context` — inject via handler struct or closure
- Do not use `gin.Default()` in production without customizing the logger and recovery middleware
