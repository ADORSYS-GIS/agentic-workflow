## Gorilla Mux Conventions

### Project Structure
- Entry point: `cmd/server/main.go` with `r := mux.NewRouter()` and `http.ListenAndServe`
- Handlers: `internal/handler/{resource}.go` using standard `http.HandlerFunc`
- Services: `internal/service/{resource}.go` for business logic
- Models: `internal/model/` for domain and request/response types
- Middleware: `internal/middleware/` for custom middleware
- Routes: `internal/router/router.go` for centralized route definitions

### Route Patterns
- Define routes: `r.HandleFunc("/api/users/{id}", handler.GetUser).Methods("GET")`
- Subrouters: `api := r.PathPrefix("/api/v1").Subrouter()` for grouped routes
- Path variables: `mux.Vars(r)["id"]` to extract URL parameters
- Query constraints: `r.Queries("page", "{page:[0-9]+}")` for typed query matching
- Host-based routing: `r.Host("{subdomain}.example.com").HandlerFunc(handler)`
- Methods: chain `.Methods("GET", "POST")` to restrict HTTP methods per route

### Middleware
- Use `r.Use(middleware)` for global middleware on the router
- Middleware signature: `func(next http.Handler) http.Handler`
- Common middleware: logging, recovery, CORS, request ID, auth
- Subrouter middleware: `api.Use(authMiddleware)` applies only to subrouter routes
- Gorilla handlers package: `handlers.LoggingHandler`, `handlers.CORS`, `handlers.CompressHandler`

### Handler Patterns
- Standard Go HTTP handlers: `func(w http.ResponseWriter, r *http.Request)`
- Extract path vars: `vars := mux.Vars(r); id := vars["id"]`
- Parse JSON body: `json.NewDecoder(r.Body).Decode(&req)` with error checking
- Write JSON response: set `Content-Type`, use `json.NewEncoder(w).Encode(data)`
- Set status codes: `w.WriteHeader(http.StatusCreated)` BEFORE writing the body

### Route Matching
- Routes match in order of specificity, not declaration order
- Use regex constraints: `r.HandleFunc("/users/{id:[0-9]+}", handler)`
- Use `r.NotFoundHandler` for custom 404 responses
- Use `r.MethodNotAllowedHandler` for custom 405 responses
- Test route matching: `mux.CurrentRoute(r)` to inspect matched route

### Testing
- Handlers are standard `http.HandlerFunc` — use `httptest.NewRecorder()` and `httptest.NewRequest()`
- For route-parameter-dependent handlers: use `mux.SetURLVars(r, map[string]string{"id": "123"})` in tests
- Test middleware by wrapping handlers in test assertions

### Anti-Patterns to Avoid
- Do not forget to call `mux.Vars(r)` within the handler — it uses request context
- Do not write response body before `WriteHeader` — the default 200 is set on first write
- Do not define overly broad path prefixes that shadow more specific routes
- Do not skip error handling on `json.NewDecoder().Decode()` — malformed JSON should return 400
- Do not put business logic in HTTP handlers — delegate to service layer
