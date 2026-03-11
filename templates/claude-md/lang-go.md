## Go Conventions

### Naming
- Exported identifiers: `PascalCase` (functions, types, constants, variables)
- Unexported identifiers: `camelCase`
- Packages: short, lowercase, single-word (e.g., `http`, `user`, `auth`) — no underscores or camelCase
- Interfaces: name by behavior with `-er` suffix (`Reader`, `Storer`, `Validator`)
- Receiver variables: short, 1-2 letter abbreviation of the type (`func (u *User) Name()`)
- Acronyms: all caps (`HTTP`, `URL`, `ID`), not `Http`, `Url`, `Id`
- Files: `snake_case.go`; test files: `snake_case_test.go`

### Package Organization
- Organize by domain/feature, not by technical layer (avoid `models/`, `controllers/`, `services/`)
- Keep `main` packages minimal — they should only wire dependencies and start the application
- Use `internal/` to prevent external packages from importing implementation details
- Avoid circular imports by extracting shared types into a separate package
- One package per directory; package name matches directory name

### Error Handling
- Always check errors — never discard with `_` unless you have a documented reason
- Return errors as the last return value: `func Foo() (Result, error)`
- Use `fmt.Errorf("context: %w", err)` to wrap errors with context
- Define sentinel errors with `var ErrNotFound = errors.New("not found")` for comparison with `errors.Is()`
- Use custom error types implementing `error` interface for errors that carry structured data
- Never panic in library code; panic is acceptable only for truly unrecoverable states in `main`

### Type Safety and Idioms
- Prefer composition over embedding; embed only when the full interface should be promoted
- Use `context.Context` as the first parameter of functions that do I/O or are cancellable
- Use struct literals with field names: `User{Name: "Alice", Age: 30}`, never positional
- Prefer `sync.Mutex` over channels for protecting shared state; channels for communication
- Use `defer` for cleanup (closing files, releasing locks) — it runs LIFO
- Use `iota` for enumerations with a defined type

### Concurrency Patterns
- Do not start goroutines without a plan for how they end — avoid goroutine leaks
- Use `errgroup.Group` for managing groups of goroutines that return errors
- Pass `context.Context` through the call chain for cancellation propagation
- Prefer `sync.WaitGroup` for simple fork-join parallelism
- Never close a channel from the receiver side; only the sender closes channels

### Common Pitfalls
- Do not use `init()` functions for complex logic; they make testing difficult
- Beware of nil interface values — a nil pointer in a non-nil interface is not `== nil`
- Slices share underlying arrays; mutations to a sub-slice affect the original
- Always handle the `ok` value from map lookups and type assertions
- Do not rely on goroutine scheduling order; it is non-deterministic
- Use `go vet`, `staticcheck`, and `golangci-lint` in CI
