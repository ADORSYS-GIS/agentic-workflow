## Flask Conventions

### Project Structure
- Use the application factory pattern: `create_app()` in `app/__init__.py`
- Blueprints: `app/{feature}/` with `routes.py`, `models.py`, `services.py`, `schemas.py`
- Register blueprints with URL prefixes: `app.register_blueprint(users_bp, url_prefix='/api/users')`
- Configuration: `config.py` with `Development`, `Production`, `Testing` classes
- Extensions: initialize in `app/extensions.py` (db, migrate, login_manager), init in factory
- Templates: `app/templates/`; static: `app/static/`

### Route Patterns
- Use blueprints for every feature — never define routes on the main app object
- Decorate with specific methods: `@bp.route('/users', methods=['GET'])` or use `@bp.get('/users')`
- Return tuples for non-200 responses: `return jsonify(error='Not found'), 404`
- Use `flask.abort(404)` for quick error responses; register custom error handlers with `@app.errorhandler`
- Access request data via `request.json`, `request.args`, `request.form` — validate before use

### Request Validation
- Use Marshmallow or Pydantic for request/response schema validation
- Validate early in the route handler; return 400 with field-level error details
- Use `@expects_json` or custom decorators to enforce `Content-Type: application/json`
- Never trust `request.json` without validation — it can be any shape

### Database and Models
- Use Flask-SQLAlchemy with the application factory pattern
- Define models in `app/{feature}/models.py`; import in `app/models.py` for Alembic discovery
- Use Flask-Migrate (Alembic) for schema migrations — never modify the database manually
- Use `db.session.commit()` explicitly; configure autocommit/autoflush carefully
- Avoid lazy loading in API responses — use `joinedload` or `selectinload` to prevent N+1

### Error Handling
- Register global error handlers: `@app.errorhandler(404)`, `@app.errorhandler(Exception)`
- Return consistent JSON error responses: `{ "error": { "code": "NOT_FOUND", "message": "..." } }`
- Log exceptions with `app.logger.exception()` for full stack traces
- Never expose internal error details in production — use generic messages

### Anti-Patterns to Avoid
- Do not use the global `app` object — use the factory pattern and `current_app`
- Do not import the app instance in modules — use `current_app` proxy
- Do not put business logic in route handlers — delegate to service functions
- Do not use Flask's `g` object for data that should be passed explicitly
- Do not skip database migrations — manual schema changes cause drift
