## CakePHP Conventions

### Project Structure
- Follow CakePHP conventions: `src/Controller/`, `src/Model/`, `templates/`, `config/`
- Controllers: `src/Controller/{Feature}Controller.php` extending `AppController`
- Models: `src/Model/Table/{Entity}Table.php` and `src/Model/Entity/{Entity}.php`
- Templates: `templates/{Controller}/{action}.php` for view templates
- Middleware: `src/Middleware/` for HTTP middleware
- Commands: `src/Command/` for CLI commands
- Plugins: `plugins/` for reusable modular features
- Config: `config/` with `app.php`, `routes.php`, `bootstrap.php`

### Naming Conventions (Critical in CakePHP)
- CakePHP uses naming conventions for automatic associations — follow them strictly
- Tables: plural snake_case (`users`, `blog_posts`)
- Models: `UsersTable.php`, `BlogPostsTable.php` (plural PascalCase + Table)
- Entities: `User.php`, `BlogPost.php` (singular PascalCase)
- Controllers: `UsersController.php` (plural PascalCase + Controller)
- Foreign keys: `user_id` (singular table name + `_id`)
- Templates: `templates/Users/index.php` (controller name / action name)

### Controller Patterns
- Keep controllers thin: load data from models, pass to views
- Use `$this->paginate()` for list endpoints with pagination
- Authorization: use the Authorization plugin with policies
- Request data: `$this->request->getData()`, `$this->request->getQuery()`
- JSON APIs: use `$this->set('data', $data); $this->viewBuilder()->setOption('serialize', ['data'])`

### Model Patterns (Table + Entity)
- Table: define associations, validation rules, behaviors, and custom finders
- Associations: `$this->hasMany('Posts')`, `$this->belongsTo('Users')` — CakePHP infers from naming
- Validation: `$validator->requirePresence('email', 'create')->notEmptyString('email')->email('email')`
- Custom finders: `public function findActive(Query $query) { return $query->where(['active' => true]); }`
- Entity: define virtual fields, accessors, mutators with `_get{Field}` and `_set{Field}`
- Behaviors: `$this->addBehavior('Timestamp')`, `$this->addBehavior('Tree')` for reusable model logic

### Routing
- Define in `config/routes.php` using the route builder
- RESTful: `$routes->resources('Users')` generates all CRUD routes
- Scoped routes: `$routes->prefix('Api/V1', function ($routes) { ... })`
- Connect: `$routes->connect('/login', ['controller' => 'Users', 'action' => 'login'])`
- Named routes: pass `['_name' => 'users:list']` for URL generation

### Migrations
- Use `bin/cake bake migration CreateUsers` for migration generation
- Define schema changes in `up()` and `down()` methods
- Run: `bin/cake migrations migrate`; rollback: `bin/cake migrations rollback`
- Use seeds for development data: `bin/cake bake seed Users`

### Anti-Patterns to Avoid
- Do not break naming conventions — CakePHP's magic depends on them
- Do not put business logic in controllers — use model methods, behaviors, or service classes
- Do not use raw SQL when the ORM can express the query
- Do not skip validation rules on Table classes — they are the primary data integrity layer
- Do not use `contain()` without limiting fields — it can load massive amounts of associated data
