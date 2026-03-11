## Chi Conventions

### Project Structure
- Entry point: `cmd/server/main.go` with `r := chi.NewRouter()` and `http.ListenAndServe`
- Handlers: `internal/handler/{resource}.go` using standard `http.HandlerFunc`
- Services: `internal/service/{resource}.go` for business logic
- Repositories: `internal/repository/{resource}.go` for data access
- Models: `internal/model/` for domain and request/response types
- Middleware: `internal/middleware/` for custom middleware
- Routes: `internal/router/router.go` for route composition

### Route Patterns
- Use `r.Route("/api/v1/users", func(r chi.Router) { ... })` for sub-routers
- RESTful: `r.Get("/", listUsers)`, `r.Post("/", createUser)`, `r.Get("/{id}", getUser)`
- URL params: `chi.URLParam(r, "id")` from the request context
- Mount sub-routers: `r.Mount("/admin", adminRouter())` for modular composition
- Chi is 100% compatible with `net/http` — handlers use standard `http.ResponseWriter` and `*http.Request`

### Middleware
- Built-in middleware: `r.Use(middleware.Logger, middleware.Recoverer, middleware.RequestID)`
- `middleware.Timeout(60 * time.Second)` for request timeout enforcement
- `middleware.AllowContentType("application/json")` to restrict content types
- `middleware.RealIP` for extracting real client IP behind proxies
- Group-specific middleware: `r.Group(func(r chi.Router) { r.Use(authMiddleware); r.Get("/profile", getProfile) })`

### Handler Patterns
- Use standard `func(w http.ResponseWriter, r *http.Request)` signature
- Parse JSON body: `json.NewDecoder(r.Body).Decode(&req)` — always check errors
- Respond with JSON: write `Content-Type` header, encode with `json.NewEncoder(w).Encode(data)`
- Extract context values: `ctx := r.Context()`, `userID := ctx.Value("userID").(string)`
- Use `render` package or helper functions for consistent response formatting

### Context Usage
- Chi uses `context.Context` for passing route parameters and middleware data
- Use `chi.RouteContext(r.Context())` for advanced route introspection
- Pass request-scoped data via `context.WithValue` in middleware
- Use typed context keys to avoid collisions: `type ctxKey string`

### Testing
- Chi handlers are standard `http.HandlerFunc` — test with `httptest.NewRecorder()` and `httptest.NewRequest()`
- Test middleware by wrapping handlers in test setup
- Use `chi.NewRouter()` in tests for integration testing with actual routing

### Anti-Patterns to Avoid
- Do not use string keys for context values — use typed keys to prevent collisions
- Do not forget to close `r.Body` — though Go GC handles it, explicit close is best practice
- Do not write to `http.ResponseWriter` after calling `WriteHeader` with a different status
- Do not skip `middleware.Recoverer` — unhandled panics crash the server
- Do not put business logic in handlers — keep them as thin adapters
