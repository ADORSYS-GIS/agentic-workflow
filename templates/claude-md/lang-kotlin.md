## Kotlin Conventions

### Naming
- Variables, functions, parameters: `camelCase`
- Classes, interfaces, objects, enums: `PascalCase`
- Constants (`const val` or top-level `val`): `SCREAMING_SNAKE_CASE` for true constants, `camelCase` for computed vals
- Packages: `lowercase.dotted`, matching directory structure
- Files: `PascalCase.kt` for single-class files; `camelCase.kt` or descriptive name for multi-declaration files
- Extension functions: place in `Extensions.kt` or next to the type they extend
- Backing properties: `_privateState` with public `publicState` exposure

### Type Safety
- Leverage Kotlin's null safety — never use `!!` except in tests; prefer `?.`, `?:`, and `let`
- Use `sealed class`/`sealed interface` for restricted hierarchies with exhaustive `when`
- Use `data class` for value objects; `value class` (inline) for type-safe wrappers
- Prefer `Result<T>` or Arrow's `Either` for operations that can fail
- Use `require()` and `check()` for preconditions and state validation
- Avoid platform types from Java interop — annotate or wrap them immediately

### Import Organization
- Order: (1) `kotlin.*`, (2) `java.*`, (3) third-party, (4) project-internal
- Remove unused imports; do not use wildcard imports
- Use import aliases sparingly and only to resolve conflicts

### Error Handling
- Use `runCatching` for wrapping exceptions into `Result<T>`
- Use sealed class hierarchies for domain error modeling
- Catch specific exceptions; never catch `Throwable` broadly
- Use `use {}` extension (Kotlin's try-with-resources) for `Closeable` resources
- Coroutine exceptions: use `CoroutineExceptionHandler` and structured concurrency

### Patterns and Idioms
- Prefer `val` over `var`; prefer immutable collections (`listOf`, `mapOf`) over mutable ones
- Use extension functions to add behavior without inheritance
- Use `when` expressions exhaustively (sealed types) — avoid `else` branches on sealed hierarchies
- Use `apply`, `also`, `let`, `run`, `with` appropriately: `apply` for configuration, `let` for null-safe transforms, `also` for side effects
- Use Kotlin coroutines for async work; prefer `suspend` functions over callback-based APIs
- Use `object` for singletons; `companion object` for factory methods
- Prefer `sequence {}` over `List` chains for lazy evaluation of large collections

### Common Pitfalls
- Avoid `lateinit` for nullable types or primitives; use `lazy` for expensive initialization
- Do not use `data class` for entities with mutable state or JPA entities (breaks identity semantics)
- Beware of coroutine scope leaks — always use structured concurrency (`coroutineScope`, `supervisorScope`)
- Avoid `GlobalScope.launch`; inject a `CoroutineScope` or use lifecycle-aware scopes
- Do not mix Java streams with Kotlin sequences/collections — pick one paradigm
- Remember that `==` in Kotlin is structural equality (calls `equals`); use `===` for referential equality
