## Pyramid Conventions

### Project Structure
- Entry point: `app/__init__.py` with `Configurator` and `main()` function
- Views: `app/views/{resource}.py` with view callables or view classes
- Models: `app/models/` for SQLAlchemy models with `__init__.py` aggregating metadata
- Templates: `app/templates/` using Jinja2 or Chameleon
- Routes: defined in `app/routes.py` or `app/__init__.py` via `config.add_route()`
- Static files: `app/static/`
- Tests: `tests/` with `conftest.py` for fixtures

### Route and View Patterns
- Define routes explicitly: `config.add_route('user_detail', '/users/{id}')` — name every route
- Use `@view_config(route_name='user_detail', renderer='json')` to bind views to routes
- Use `@view_defaults(route_name='users')` for view classes with multiple methods
- Prefer view classes for resources with multiple HTTP methods
- Use `request.matchdict` for URL parameters, `request.json_body` for JSON payloads

### Configuration and Includes
- Use `config.include()` for modular configuration of features
- Split configuration into includes: `config.include('.routes')`, `config.include('.models')`
- Use `config.scan()` to discover `@view_config` decorated views
- Use `.ini` files for deployment configuration; `config.add_settings()` for app settings
- Use `config.add_request_method()` to extend the request object with custom properties

### Security and Authorization
- Use Pyramid's built-in security framework with policies
- Define an `AuthenticationPolicy` and `AuthorizationPolicy`
- Use ACL (Access Control Lists) on resources for fine-grained permissions
- Use `@view_config(permission='edit')` to require permissions on views
- Use `remember()` and `forget()` for session/cookie management

### Database Patterns
- Use SQLAlchemy with `transaction` package for request-scoped transactions
- Transaction commits automatically on successful responses; rolls back on exceptions
- Define models with `Base = declarative_base()` in `models/meta.py`
- Use Alembic for migrations; auto-generate from model changes

### Anti-Patterns to Avoid
- Do not bypass Pyramid's security framework with manual auth checks in views
- Do not use global state — use Pyramid's registry and request object for dependency injection
- Do not put business logic in view callables — delegate to service functions
- Do not skip route naming — named routes enable `request.route_url()` for URL generation
- Do not define all routes in one file for large apps — use `config.include()` per feature
