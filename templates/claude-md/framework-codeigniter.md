## CodeIgniter Conventions

### Project Structure
- Follow CI4 structure: `app/Controllers/`, `app/Models/`, `app/Views/`, `app/Filters/`
- Controllers: `app/Controllers/{Feature}.php` extending `BaseController`
- Models: `app/Models/{Entity}Model.php` extending `Model`
- Views: `app/Views/{feature}/` with PHP template files
- Filters: `app/Filters/` for request/response middleware
- Libraries: `app/Libraries/` for reusable utility classes
- Config: `app/Config/` for application configuration classes
- Routes: `app/Config/Routes.php` for route definitions

### Controller Patterns
- Extend `BaseController` or `ResourceController` for RESTful APIs
- `ResourceController`: provides `index`, `show`, `create`, `update`, `delete` methods
- Access request: `$this->request->getJSON()`, `$this->request->getGet('page')`
- Response: `return $this->respond($data)`, `$this->respondCreated($data)`, `$this->failNotFound()`
- Use `$this->validator` for input validation with rules from `app/Config/Validation.php`

### Model Patterns
- Define models with properties: `$table`, `$primaryKey`, `$allowedFields`, `$returnType`
- Use `$allowedFields` to prevent mass assignment vulnerabilities
- Built-in timestamps: `$useTimestamps = true` with `$createdField` and `$updatedField`
- Validation rules in model: `$validationRules = ['email' => 'required|valid_email|is_unique[users.email]']`
- Query builder: `$this->where('active', 1)->findAll()`, `$this->insert($data)`
- Soft deletes: `$useSoftDeletes = true` with `$deletedField`

### Routing
- Define in `app/Config/Routes.php`: `$routes->get('users/(:num)', 'Users::show/$1')`
- Resource routes: `$routes->resource('users')` generates all RESTful routes
- Route groups: `$routes->group('api', ['filter' => 'auth'], function ($routes) { ... })`
- Named routes: `$routes->get('users', 'Users::index', ['as' => 'users.list'])`
- Placeholders: `(:num)`, `(:alpha)`, `(:alphanum)`, `(:segment)`, `(:any)`

### Filters (Middleware)
- Define in `app/Filters/`: implement `FilterInterface` with `before()` and `after()` methods
- Register in `app/Config/Filters.php`: aliases, global, and per-route filters
- Use `before` for auth, CORS, rate limiting; `after` for response modification
- Apply per-route: `$routes->get('admin', 'Admin::index', ['filter' => 'admin-auth'])`

### Validation
- Validate in controller: `$this->validate(['email' => 'required|valid_email'])`
- Custom rules: define in `app/Validation/` and register in config
- Access errors: `$this->validator->getErrors()` for field-level error messages
- Model validation runs automatically on `insert()` and `update()` if rules are defined

### Anti-Patterns to Avoid
- Do not put business logic in controllers — extract to models, libraries, or services
- Do not use raw queries with user input — use query builder with parameter binding
- Do not skip `$allowedFields` on models — it is the primary mass assignment protection
- Do not disable CSRF protection — configure exceptions only for specific API routes
- Do not use `$_GET`, `$_POST`, `$_REQUEST` — use CI4's `$this->request` object
