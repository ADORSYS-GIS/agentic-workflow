## Java Conventions

### Naming
- Variables, methods, parameters: `camelCase`
- Classes, interfaces, enums, records: `PascalCase`
- Constants (`static final`): `SCREAMING_SNAKE_CASE`
- Packages: `lowercase.dotted` (reverse domain, e.g., `com.company.project.module`)
- Files: one public class per file, filename matches class name exactly
- Test classes: `ClassNameTest.java`; test methods: `shouldDoSomething_whenCondition`

### Type Safety
- Use generics everywhere; never use raw types (`List` without `<T>`)
- Prefer `Optional<T>` for return types that may be absent; never return `null` from public methods
- Use `sealed` classes/interfaces (Java 17+) for exhaustive type hierarchies
- Prefer records for immutable data carriers
- Use `@Nullable`/`@NonNull` annotations from your chosen library (JSR-305 or JetBrains)
- Avoid autoboxing in performance-sensitive code; prefer primitive types where possible

### Import Organization
- Order: (1) `java.*`, (2) `javax.*`, (3) third-party, (4) project-internal — separated by blank lines
- Never use wildcard imports (`import java.util.*`); import specific classes
- Remove unused imports (configure IDE/CI to enforce)
- Static imports only for constants and assertion methods in tests

### Error Handling
- Use checked exceptions for recoverable conditions; unchecked for programming errors
- Never catch `Throwable` or `Error` unless you are in a top-level handler
- Always include the original exception as the cause when wrapping: `throw new AppException("msg", e)`
- Use try-with-resources for all `AutoCloseable` resources
- Define a project-level exception hierarchy (e.g., `AppException -> NotFoundException, ValidationException`)
- Never use exceptions for control flow

### Patterns and Idioms
- Prefer immutability: `final` fields, unmodifiable collections, records
- Use the Builder pattern for objects with many optional parameters
- Prefer dependency injection over static factory methods for testability
- Use `Stream` API for collection transformations, but avoid deeply nested streams
- Use `var` (Java 10+) for local variables when the type is obvious from the right-hand side
- Prefer `java.time` API over `Date`/`Calendar`
- Use `EnumSet`/`EnumMap` instead of `HashSet`/`HashMap` for enum keys

### Common Pitfalls
- Always override `hashCode()` when overriding `equals()`
- Do not compare strings with `==`; always use `.equals()`
- Beware of `ConcurrentModificationException` — do not modify collections during iteration
- Do not swallow exceptions in catch blocks; at minimum, log them
- Avoid `synchronized` blocks with broad scope; use `java.util.concurrent` utilities
- Close database connections, HTTP clients, and I/O streams explicitly in `finally` or try-with-resources
