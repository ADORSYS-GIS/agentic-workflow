## Rust Conventions

### Naming
- Variables, functions, methods, modules: `snake_case`
- Types, traits, enums: `PascalCase`
- Constants and statics: `SCREAMING_SNAKE_CASE`
- Lifetime parameters: short lowercase (`'a`, `'b`); use descriptive names for clarity (`'conn`, `'ctx`)
- Crate names: `kebab-case` in Cargo.toml, `snake_case` in code (auto-converted)
- Files: `snake_case.rs`; module directories with `mod.rs` or `module_name.rs` + `module_name/`
- Type conversions: `from_*`, `to_*`, `into_*`, `as_*` following std conventions

### Ownership and Borrowing
- Default to borrowing (`&T`); only take ownership when the function needs to consume or store the value
- Prefer `&str` over `&String`, `&[T]` over `&Vec<T>` in function parameters
- Use `Clone` explicitly rather than implicit copies; annotate why a clone is necessary if non-obvious
- Return owned types from constructors and factory functions
- Minimize lifetime annotations — let the compiler infer where possible
- Use `Cow<'_, str>` when a function may or may not need to allocate

### Error Handling
- Use `Result<T, E>` for all fallible operations; never panic in library code
- Define a crate-level error enum using `thiserror` for libraries or `anyhow` for applications
- Use the `?` operator for error propagation; add context with `.context()` (anyhow) or `.map_err()`
- Reserve `unwrap()` and `expect()` for cases with compile-time or logical guarantees; always add a message to `expect()`
- Use `panic!` only for programming errors (invariant violations), never for expected failures

### Module Organization
- Keep `lib.rs`/`main.rs` thin — re-export public API and delegate to submodules
- Use `pub(crate)` for internal visibility; minimize the public surface area
- Group related types, traits, and functions into modules by domain concept
- Place integration tests in `tests/` directory; unit tests in `#[cfg(test)]` modules within source files

### Patterns and Idioms
- Use `enum` with variants for state machines and discriminated unions
- Implement `Display` and `Debug` for all public types
- Use `impl Into<T>` / `impl AsRef<T>` for flexible function parameters
- Prefer iterators and combinators (`.map()`, `.filter()`, `.collect()`) over manual loops
- Use `derive` macros for `Debug`, `Clone`, `PartialEq`, `Eq`, `Hash`, `Serialize`, `Deserialize` as appropriate
- Prefer `Option` methods (`.map()`, `.and_then()`, `.unwrap_or_default()`) over `match` for simple cases
- Use newtype pattern (`struct UserId(u64)`) for type safety on primitive wrappers

### Common Pitfalls
- Avoid `String::from` / `.to_string()` in hot loops; reuse buffers
- Beware of holding `MutexGuard` across `.await` points — use `tokio::sync::Mutex` in async code
- Do not use `Rc`/`Arc` unless shared ownership is truly needed
- Avoid `unsafe` unless absolutely necessary; document safety invariants in `// SAFETY:` comments
- Run `cargo clippy` in CI and fix all warnings; do not suppress without justification
- Use `#[must_use]` on functions whose return values should not be ignored
