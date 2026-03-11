## PHP Conventions

### Naming
- Variables, functions: `camelCase` (PSR-12) or `snake_case` (Laravel convention) — choose one and be consistent
- Classes, interfaces, traits, enums: `PascalCase`
- Constants: `SCREAMING_SNAKE_CASE`
- Namespaces: `PascalCase`, mirroring directory structure (PSR-4)
- Files: `PascalCase.php` matching the class name exactly
- Interfaces: suffix with `Interface` (e.g., `UserRepositoryInterface`) per PSR convention
- Abstract classes: prefix with `Abstract` (e.g., `AbstractController`)

### Type Safety
- Declare `strict_types=1` at the top of every file: `declare(strict_types=1);`
- Use typed properties, parameters, and return types everywhere (PHP 8.0+)
- Use union types (`string|int`), intersection types (`Countable&Iterator`), and `null` explicitly
- Use `enum` (PHP 8.1+) for fixed sets of values instead of class constants
- Use `readonly` properties (PHP 8.1+) and `readonly` classes (PHP 8.2+) for immutable data
- Never rely on type juggling; always use strict comparison (`===`, `!==`)

### Namespace and Autoloading
- Follow PSR-4 autoloading: namespace maps to directory, class maps to filename
- One class per file; file named identically to the class
- Group `use` statements at the top: (1) PHP built-in, (2) framework, (3) third-party, (4) project
- Use `use` imports instead of fully qualified class names in code

### Error Handling
- Use exceptions for error handling, not return codes
- Catch specific exception types; avoid catching `\Exception` or `\Throwable` broadly
- Create a project exception hierarchy extending a base `AppException`
- Use `try`/`finally` for cleanup (closing connections, releasing locks)
- Set a global exception handler for unhandled exceptions in production
- Log exceptions with full context (message, code, trace, request data)

### Patterns and Idioms
- Use constructor promotion (PHP 8.0+): `public function __construct(private readonly string $name)`
- Use named arguments for functions with many parameters or boolean flags
- Prefer match expressions over switch for simple value mapping
- Use null-safe operator (`?->`) instead of nested null checks
- Use array destructuring: `[$first, $second] = $array`
- Use generators (`yield`) for processing large datasets without loading all into memory
- Use attributes (PHP 8.0+) instead of docblock annotations where supported

### Common Pitfalls
- Always use `===` and `!==`; PHP's loose comparison (`==`) has surprising type coercion rules
- Beware of `array_merge` in loops — it has O(n) cost each call; use spread operator or `array_push`
- Never trust user input: filter, validate, and sanitize all inputs
- Escape output appropriately: `htmlspecialchars()` for HTML, parameterized queries for SQL
- Avoid `global` keyword and global state; use dependency injection
- Do not suppress errors with `@` operator; fix the root cause
- Run `phpstan` or `psalm` at the highest level in CI
