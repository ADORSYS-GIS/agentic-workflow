## Ruby Conventions

### Naming
- Variables, methods, symbols: `snake_case`
- Classes, modules: `PascalCase` (CamelCase)
- Constants: `SCREAMING_SNAKE_CASE`
- Predicate methods: suffix with `?` (e.g., `valid?`, `admin?`)
- Dangerous/mutating methods: suffix with `!` (e.g., `save!`, `sort!`)
- Files: `snake_case.rb`, matching the primary class/module name
- Private methods: no underscore prefix — use `private` keyword instead

### Module Organization
- One class/module per file unless inner classes are tightly coupled
- Use `require_relative` for project files; `require` for gems
- Organize by domain: `app/models/`, `app/services/`, `lib/`
- Namespace modules to avoid collisions (e.g., `MyApp::Services::UserCreator`)
- Use `autoload` or Zeitwerk for lazy loading in libraries/frameworks

### Error Handling
- Rescue specific exceptions, never bare `rescue` (which catches `StandardError`)
- Define custom exception classes inheriting from `StandardError`
- Use `raise` with a message: `raise ArgumentError, "name is required"`
- Use `ensure` blocks for cleanup (equivalent to `finally`)
- Use `retry` with a counter to prevent infinite loops
- Never rescue `Exception` — it catches `SignalException`, `SystemExit`, etc.

### Patterns and Idioms
- Prefer `frozen_string_literal: true` magic comment at the top of every file
- Use blocks and `yield` for iteration and callbacks
- Prefer `Symbol` keys over `String` keys in hashes
- Use `Hash#fetch` instead of `Hash#[]` when missing keys should raise errors
- Use `%w[]` and `%i[]` for word and symbol arrays
- Prefer `each_with_object` or `transform_values` over `inject`/`reduce` for building hashes
- Use `Struct` or `Data` (Ruby 3.2+) for simple value objects
- Use `Enumerable` methods over manual iteration

### Style
- Two-space indentation (not tabs)
- Use `do...end` for multi-line blocks; `{ }` for single-line blocks
- Omit `return` for the last expression in a method (implicit return)
- Use guard clauses (`return unless condition`) over deeply nested conditionals
- Prefer string interpolation over concatenation: `"Hello, #{name}"`
- Use `&&`/`||` for boolean logic; `and`/`or` only for control flow

### Common Pitfalls
- Beware of mutable default arguments — `def foo(items = [])` shares the array across calls in some patterns
- Do not modify a collection while iterating; use `select`/`reject` to create a new one
- Beware of `nil` returns from `Hash#[]`, `Array#[]` — use `fetch` for safety
- Avoid monkey-patching core classes; use Refinements if you must extend them
- Use `freeze` on constants to prevent accidental mutation
- Run `rubocop` in CI to enforce consistent style
