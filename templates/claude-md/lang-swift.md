## Swift Conventions

### Naming
- Variables, functions, parameters, enum cases: `camelCase`
- Types (classes, structs, enums, protocols): `PascalCase`
- Protocols describing capability: use `-able`, `-ible`, or `-ing` suffix (e.g., `Codable`, `Sendable`)
- Protocols describing "what it is": use noun (e.g., `Collection`, `View`)
- Boolean properties: read as assertions (`isEnabled`, `hasContent`, `shouldRefresh`)
- Files: `PascalCase.swift`, named after the primary type
- Factory methods: prefix with `make` (e.g., `makeUserView()`)

### Type Safety
- Leverage Swift's strong type system — avoid `Any` and `AnyObject` unless interfacing with Obj-C
- Use `Optional` explicitly; never force-unwrap (`!`) outside of `IBOutlet` or truly guaranteed contexts
- Prefer `guard let` for early exits over nested `if let`
- Use `enum` with associated values for modeling distinct states (avoid boolean flags)
- Use `Result<Success, Failure>` for operations that can fail
- Use `Codable` for serialization; prefer `CodingKeys` over manual encode/decode

### Code Organization
- Use `// MARK: -` comments to organize sections: Properties, Initialization, Public Methods, Private Methods
- Use extensions to separate protocol conformances into their own blocks
- Keep files focused on a single type; helper types can be in the same file if tightly coupled
- Group files by feature, not by type (prefer `Features/Auth/` over `Models/`, `Views/`, `ViewModels/`)

### Error Handling
- Use `throws` functions and `do`/`catch` for recoverable errors
- Define domain-specific error enums conforming to `Error` (and `LocalizedError` for user-facing messages)
- Use `Result` type for async callbacks that can fail (pre-async/await code)
- Never ignore errors — at minimum log them
- Use `try?` only when the nil case is genuinely acceptable; prefer `try` with `catch`

### Patterns and Idioms
- Prefer value types (`struct`, `enum`) over reference types (`class`) — use `class` only when identity or inheritance is needed
- Use `protocol`-oriented design: define behavior with protocols, implement with extensions
- Use `lazy var` for expensive computations that may not be needed
- Use `@discardableResult` for functions whose return value is optional to use
- Prefer `map`, `filter`, `compactMap`, `flatMap` for collection transformations
- Use `defer` for cleanup code that must run regardless of exit path
- Prefer `async`/`await` and structured concurrency with `TaskGroup` (Swift 5.5+)

### Concurrency (Swift Concurrency)
- Use `actor` for shared mutable state instead of manual locking
- Mark types as `Sendable` when they cross concurrency boundaries
- Use `@MainActor` for UI-bound code
- Avoid data races by using structured concurrency (`async let`, `TaskGroup`)
- Never block the main thread with synchronous work

### Common Pitfalls
- Beware of retain cycles in closures — use `[weak self]` or `[unowned self]` appropriately
- Do not use `unowned` unless you can guarantee the reference outlives the closure
- Avoid force-casting (`as!`); use conditional casting (`as?`) with proper handling
- Remember that `struct` is value-type — mutations on copies do not affect the original
- Do not use `NSNotificationCenter` for everything — prefer delegates, closures, or Combine/async streams
