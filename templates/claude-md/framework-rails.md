## Ruby on Rails Conventions

### Project Structure
- Follow Rails conventions: `app/models/`, `app/controllers/`, `app/views/`, `app/services/`
- Business logic: extract to `app/services/` (service objects) or `app/models/` (domain logic)
- Background jobs: `app/jobs/` using ActiveJob with Sidekiq or similar backend
- Serializers: `app/serializers/` for API response formatting (ActiveModelSerializers or Blueprinter)
- Form objects: `app/forms/` for complex form validation logic
- Query objects: `app/queries/` for complex database queries

### Model Patterns
- Keep models focused on data integrity: validations, associations, scopes
- Use `has_many`, `belongs_to`, `has_one` for associations with explicit `dependent:` option
- Define scopes for reusable queries: `scope :active, -> { where(active: true) }`
- Use `enum` for status fields: `enum status: { draft: 0, published: 1, archived: 2 }`
- Validate at the model level: `validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }`
- Use callbacks sparingly — prefer service objects for complex side effects

### Controller Patterns
- Keep controllers thin: parse params, call service/model, render response
- Use `before_action` for shared logic: authentication, loading resources
- Strong parameters: `params.require(:user).permit(:name, :email)` — never skip
- RESTful actions only: `index`, `show`, `create`, `update`, `destroy` — create new controllers for non-RESTful actions
- API controllers: inherit from `ActionController::API`, render JSON with serializers

### Service Objects
- One public method per service: `call` or a descriptive name
- Return a result object (success/failure) with data and errors
- Inject dependencies via constructor for testability
- Use service objects for: multi-model operations, external API calls, complex business logic

### Database and Migrations
- Always use migrations for schema changes: `rails generate migration AddStatusToUsers status:integer`
- Add database indexes for foreign keys and frequently queried columns
- Use `add_index` with `unique: true` for uniqueness constraints (not just model validations)
- Add `null: false` and default values in migrations where appropriate
- Avoid `change` method in migrations that are not reversible — use `up`/`down`

### Testing
- Use RSpec or Minitest with FactoryBot for test data
- Model tests: validations, associations, scopes, and business logic
- Request tests: full HTTP request/response cycle for API endpoints
- System tests: Capybara for end-to-end browser testing
- Keep tests fast: mock external services, use `build_stubbed` over `create` when possible

### Anti-Patterns to Avoid
- Do not put business logic in controllers or callbacks — use service objects
- Do not use `find_by_sql` when ActiveRecord can express the query
- Do not skip N+1 query detection — use `bullet` gem and fix with `includes`/`eager_load`
- Do not use `update_all` or `delete_all` without understanding the bypass of callbacks and validations
- Do not monkey-patch Rails core classes — use concerns or plain Ruby modules
