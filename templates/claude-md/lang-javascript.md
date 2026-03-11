## JavaScript Conventions

### Naming
- Variables and functions: `camelCase`
- Classes: `PascalCase`
- Constants: `SCREAMING_SNAKE_CASE` for true compile-time constants, `camelCase` otherwise
- Files: `kebab-case.js` for modules, `PascalCase.js` for classes/components
- Private methods/properties: prefix with `#` (native private fields), not `_`
- Boolean variables: prefix with `is`, `has`, `should`, `can` (e.g., `isActive`, `hasPermission`)

### Module Organization
- Use ES modules (`import`/`export`) over CommonJS (`require`/`module.exports`) in new code
- Order imports: (1) node built-ins, (2) external packages, (3) internal modules, (4) relative — separated by blank lines
- Prefer named exports for discoverability; use default exports only for main module entry points
- Keep files under 300 lines; extract when a file handles multiple responsibilities

### Error Handling
- Always handle promise rejections — unhandled rejections crash Node.js
- Use `try/catch` around `await` calls or attach `.catch()` handlers
- Throw `Error` objects (or subclasses), never strings or plain objects
- Validate function inputs early and throw descriptive errors (fail fast)
- Use custom error classes with `name` and `code` properties for programmatic handling

### Patterns and Idioms
- Use `const` by default; use `let` only when reassignment is necessary; never use `var`
- Prefer arrow functions for callbacks and anonymous functions
- Use destructuring for function parameters and return values
- Prefer `Array.prototype` methods (`map`, `filter`, `reduce`) over `for` loops for transformations
- Use optional chaining (`?.`) and nullish coalescing (`??`) instead of manual null checks
- Prefer template literals over string concatenation
- Use `Object.freeze()` for configuration objects that must not be mutated

### Async Patterns
- Prefer `async/await` over `.then()` chains for readability
- Use `Promise.all()` for parallel independent operations; `Promise.allSettled()` when partial failure is acceptable
- Never mix callbacks and promises in the same API
- Use `AbortController` for cancellable async operations

### Common Pitfalls
- Always use `===` and `!==`; never `==` or `!=`
- Beware of `this` binding in callbacks — arrow functions inherit `this` from the enclosing scope
- Do not mutate function arguments; clone objects with spread or `structuredClone()`
- Never use dynamic code execution functions — they are security risks
- Beware of floating-point arithmetic: use libraries for financial calculations
- Never rely on object key order for logic (use `Map` for ordered key-value pairs)
- Guard against prototype pollution: validate object keys from user input
