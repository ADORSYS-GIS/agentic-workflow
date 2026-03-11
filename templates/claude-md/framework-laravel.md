## Laravel Conventions

### Project Structure
- Follow Laravel defaults: `app/Http/Controllers/`, `app/Models/`, `app/Services/`
- Business logic: `app/Services/` or `app/Actions/` — not in controllers or models
- Form requests: `app/Http/Requests/` for validation and authorization
- Resources: `app/Http/Resources/` for API response transformation
- Events/listeners: `app/Events/`, `app/Listeners/` for decoupled side effects
- Jobs: `app/Jobs/` for queued background tasks
- Policies: `app/Policies/` for authorization rules

### Controller Patterns
- Use invokable controllers (`__invoke`) for single-action controllers
- Resource controllers: `Route::apiResource('users', UserController::class)` for RESTful CRUD
- Keep controllers thin: validate (FormRequest), call service, return resource
- Use `FormRequest` classes for validation: `public function rules(): array { return [...]; }`
- Return API Resources: `return new UserResource($user)` or `UserResource::collection($users)`

### Eloquent Model Patterns
- Define relationships: `hasMany`, `belongsTo`, `belongsToMany` with explicit foreign keys
- Use scopes: `scopeActive($query)` called as `User::active()->get()`
- Use casts: `protected $casts = ['settings' => 'array', 'published_at' => 'datetime']`
- Mass assignment: define `$fillable` (allowlist) — never use `$guarded = []`
- Accessors/mutators: `Attribute::make(get: fn ($value) => ...)` (Laravel 9+ syntax)
- Use `Factory` classes for test data generation

### Service and Action Patterns
- Services: stateless classes with business logic, injected via constructor
- Actions: single-responsibility classes with a `handle()` or `execute()` method
- Use dependency injection from the container — avoid `app()` helper in services
- Return value objects or DTOs, not Eloquent models, from services

### Routing
- API routes: `routes/api.php` with `Route::middleware('auth:sanctum')` groups
- Use route model binding: `Route::get('/users/{user}', ...)` — Laravel resolves `User` automatically
- Name all routes: `Route::get('/users', ...)->name('users.index')`
- Group routes by feature: `Route::prefix('admin')->group(function () { ... })`

### Database and Migrations
- Use migrations for all schema changes: `php artisan make:migration`
- Add indexes on foreign keys and commonly queried columns
- Use `->nullable()`, `->default()`, and `->unique()` in column definitions
- Seeders in `database/seeders/` for development data; factories for test data

### Anti-Patterns to Avoid
- Do not put business logic in controllers, models, or middleware — use services
- Do not use `DB::raw()` with user input — always use parameterized queries
- Do not skip eager loading — use `with()` to prevent N+1 queries (`laravel-query-detector` in dev)
- Do not return Eloquent models directly from API endpoints — use Resources
- Do not use `env()` outside of config files — cache config in production
