## C# Conventions

### Naming
- Variables, parameters, local functions: `camelCase`
- Methods, properties, events, classes, interfaces, enums: `PascalCase`
- Private fields: `_camelCase` (leading underscore)
- Constants: `PascalCase` (not SCREAMING_SNAKE_CASE — follows .NET convention)
- Interfaces: prefix with `I` (e.g., `IUserRepository`)
- Async methods: suffix with `Async` (e.g., `GetUserAsync`)
- Files: `PascalCase.cs`, one primary type per file

### Type Safety
- Enable nullable reference types (`<Nullable>enable</Nullable>`) in all projects
- Use `record` types for immutable data transfer objects
- Prefer `string.IsNullOrEmpty()` / `string.IsNullOrWhiteSpace()` over null checks alone
- Use pattern matching (`is`, `switch` expressions) for type checking and deconstruction
- Avoid `dynamic`; use generics or interfaces instead
- Use `nameof()` instead of hardcoded strings for property/method references

### Project Organization
- Follow .NET project structure: `src/`, `tests/`, `docs/`
- One namespace per folder; namespace matches folder path
- Use `global using` directives in a `GlobalUsings.cs` file for commonly used namespaces
- Order usings: (1) `System.*`, (2) `Microsoft.*`, (3) third-party, (4) project — alphabetical within groups

### Error Handling
- Throw specific exceptions (`ArgumentNullException`, `InvalidOperationException`), not generic `Exception`
- Use `ArgumentNullException.ThrowIfNull()` (C# 10+) for guard clauses
- Never catch `Exception` broadly unless at a top-level handler (middleware, hosted service)
- Use the Result pattern or `OneOf` for domain operations that can fail predictably
- Always include the inner exception when wrapping: `throw new ServiceException("msg", ex)`
- Use `IDisposable`/`IAsyncDisposable` with `using` statements for resource cleanup

### Patterns and Idioms
- Use dependency injection via constructor injection; avoid service locator pattern
- Prefer `IReadOnlyList<T>` / `IReadOnlyCollection<T>` in return types when mutation is not needed
- Use LINQ for collection transformations; avoid LINQ in hot paths (use `for` loops instead)
- Use `CancellationToken` in all async method signatures that do I/O
- Prefer `ValueTask<T>` over `Task<T>` when the result is often synchronous
- Use `sealed` on classes that are not designed for inheritance
- Use `init` properties and required members for immutable construction

### Common Pitfalls
- Never use `async void` except for event handlers — it swallows exceptions
- Avoid `.Result` and `.Wait()` on tasks — they cause deadlocks; use `await`
- Do not compare strings with `==` for culture-sensitive comparisons; use `StringComparison`
- Beware of captured variables in closures, especially loop variables
- Avoid `GC.Collect()` — let the garbage collector manage memory
- Do not use `Thread.Sleep()` in async code; use `await Task.Delay()`
