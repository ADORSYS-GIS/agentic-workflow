## TypeScript Conventions

### Naming
- Variables and functions: `camelCase`
- Classes, interfaces, types, enums: `PascalCase`
- Constants: `SCREAMING_SNAKE_CASE` for true constants, `camelCase` for derived values
- Files: `kebab-case.ts` for modules, `PascalCase.ts` for classes/components
- Interfaces: do NOT prefix with `I` (use `UserService`, not `IUserService`)
- Type parameters: single uppercase letter (`T`, `K`, `V`) or descriptive (`TResult`, `TInput`)

### Type Safety
- Enable `strict: true` in tsconfig.json — never disable it per-file
- Avoid `any`; use `unknown` when the type is truly unknown, then narrow with type guards
- Prefer `interface` for object shapes that may be extended; use `type` for unions, intersections, and mapped types
- Use discriminated unions over optional fields for state modeling
- Leverage `as const` for literal types and `satisfies` for type-checked assignments
- Never use non-null assertions (`!`) unless you have a provable guarantee; prefer optional chaining (`?.`) and nullish coalescing (`??`)

### Imports and Modules
- Use ES module syntax (`import`/`export`), never CommonJS (`require`) in `.ts` files
- Order imports: (1) node built-ins, (2) external packages, (3) internal aliases, (4) relative imports — separated by blank lines
- Use path aliases (e.g., `@/`) instead of deep relative imports (`../../../`)
- Prefer named exports over default exports for better refactoring and tree-shaking
- Co-locate types with the module that owns them; shared types go in a `types/` directory

### Error Handling
- Use custom error classes that extend `Error` with a `code` property for programmatic handling
- Prefer `Result<T, E>` patterns or discriminated unions for expected failure paths
- Use try/catch only for truly exceptional situations
- Always type catch variables as `unknown` and narrow before use

### Patterns and Idioms
- Use `readonly` for properties and arrays that should not be mutated
- Prefer `Map`/`Set` over plain objects for dynamic key collections
- Use `enum` sparingly; prefer `as const` objects with derived union types
- Leverage template literal types for string validation where applicable
- Use generics to avoid code duplication, but keep them simple — no more than 2-3 type parameters

### Common Pitfalls
- Do not use `==`; always use `===`
- Avoid floating promises — always `await` or explicitly handle with `.catch()`
- Never mutate function parameters; return new values
- Avoid `Object.assign` for cloning; use spread or `structuredClone`
- Beware of `this` context loss in callbacks — use arrow functions or explicit binding
- Do not use `@ts-ignore`; use `@ts-expect-error` with a comment explaining why
