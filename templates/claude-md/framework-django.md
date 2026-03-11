## Django Conventions

### Project Structure
- Follow Django app convention: each feature is a Django app in `apps/{feature}/`
- App structure: `models.py`, `views.py`, `urls.py`, `serializers.py`, `admin.py`, `tests/`
- Settings: split into `settings/base.py`, `settings/dev.py`, `settings/prod.py`
- Templates: `templates/{app_name}/` per app or a shared `templates/` directory
- Static files: `static/` per app or a project-level `staticfiles/`
- Management commands: `apps/{feature}/management/commands/`

### Model Patterns
- Use explicit `related_name` on all ForeignKey and M2M fields
- Define `__str__` on every model for readable admin and debugging
- Add `class Meta` with `ordering`, `verbose_name`, and `db_table` where appropriate
- Use model managers for custom querysets: `objects = UserManager()`
- Use `UUIDField` as primary key for public-facing APIs to avoid sequential ID enumeration
- Add database indexes on fields used in filters and ordering

### View and URL Patterns
- Use class-based views (CBVs) for standard CRUD; function-based views for complex or one-off logic
- For APIs, use Django REST Framework: `ModelViewSet` for CRUD, `APIView` for custom endpoints
- URL naming: `app_name:action-resource` (e.g., `users:detail-user`)
- Always use `reverse()` or `{% url %}` for URL generation — never hardcode paths
- Apply permission classes at the view level, not in the URL config

### Serializer Patterns (DRF)
- Use `ModelSerializer` for standard CRUD; plain `Serializer` for custom input shapes
- Validate at the field level (`validate_email`) and object level (`validate`)
- Use `read_only_fields` to protect computed and auto-generated fields
- Use nested serializers sparingly — prefer flat responses with IDs and separate endpoints

### Security
- Never disable CSRF protection; use `@csrf_exempt` only for webhook endpoints with signature verification
- Use `django.contrib.auth` for authentication; extend `AbstractUser` for custom user models
- Set `AUTH_USER_MODEL` early — changing it later requires manual migration
- Use `SECRET_KEY` from environment variables; rotate periodically

### Anti-Patterns to Avoid
- Do not put business logic in views or serializers — use service functions or model methods
- Do not use raw SQL unless the ORM genuinely cannot express the query
- Do not create N+1 queries — use `select_related` (FK) and `prefetch_related` (M2M/reverse FK)
- Do not override `save()` for side effects — use signals or explicit service calls
- Do not import models at module level in signals — use string references
