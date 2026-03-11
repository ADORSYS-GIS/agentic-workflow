## Hanami Conventions

### Project Structure (Hanami 2.x)
- Follow slice architecture: `slices/{feature}/` for feature-based modules
- Each slice contains: `actions/`, `views/`, `templates/`, `repositories/`, `entities/`
- Shared code: `lib/{app_name}/` for cross-cutting concerns
- Configuration: `config/` with `app.rb`, `settings.rb`, `routes.rb`
- Providers: `config/providers/` for dependency registration (database, external services)
- Entry point: `config.ru` with Rack application

### Action Patterns
- Actions are standalone classes: one class per HTTP endpoint
- Inherit from `{App}::Action`: define `handle(request, response)` method
- Validate params with dry-validation contracts in the action
- Return response: `response.body = json(data)` or `response.status = 201`
- Use `before` callbacks for auth and shared setup logic
- Keep actions thin — delegate to operations or repositories

### Slice Architecture
- Each slice is an isolated module with its own container and dependencies
- Slices communicate through explicit interfaces, not shared state
- Register slice-specific providers in `slices/{name}/config/providers/`
- Share code between slices via `lib/` or explicit exports
- Slices encourage bounded context separation aligned with DDD

### Repository and Entity Patterns
- Repositories: inherit from `{App}::DB::Repo`, use ROM (Ruby Object Mapper)
- Entities: plain Ruby objects (structs), not ActiveRecord-style
- Repositories handle persistence; entities are pure domain objects
- Define relations in `config/db/relations/{table}.rb`
- Queries: `users_repo.users.where(active: true).to_a`

### Dependency Injection
- Hanami uses `dry-system` for auto-registration and dependency injection
- Use `include Deps["repositories.user_repo"]` to inject dependencies
- Dependencies are resolved from the container automatically
- Register external services as providers in `config/providers/`
- Prefer constructor injection via `Deps` over service locator patterns

### Validation
- Use `dry-validation` contracts for input validation
- Define contracts as classes: `class CreateUserContract < Hanami::Action::Contract`
- Contracts validate types, required fields, and business rules
- Access validation results in actions: `halt 422, json(errors: result.errors.to_h)` on failure

### Anti-Patterns to Avoid
- Do not use ActiveRecord patterns — Hanami uses ROM with explicit repositories
- Do not share state between slices via global variables — use explicit interfaces
- Do not skip dependency injection — manual instantiation defeats Hanami's container
- Do not put business logic in actions — extract to operations or service objects
- Do not use Hanami 1.x patterns in 2.x projects — the architecture changed significantly
