## Grape Conventions

### Project Structure
- API entry point: `app/api/root.rb` mounting versioned APIs
- Versioned APIs: `app/api/v1/` with individual resource files
- Entities: `app/api/v1/entities/` for response presenters (Grape Entity)
- Validators: `app/api/v1/validators/` for custom parameter validators
- Helpers: `app/api/v1/helpers/` for shared helper modules
- Mount in Rack: `config.ru` or mount in Rails routes if using with Rails

### API Definition Patterns
- Define APIs as classes inheriting from `Grape::API`
- Version: `version 'v1', using: :path` (path, header, or param strategies)
- Format: `format :json` and `content_type :json, 'application/json'`
- Mount sub-APIs: `mount V1::Users` in the root API class
- Prefix: `prefix :api` for base path

### Endpoint Patterns
- Resource blocks: `resource :users do ... end` for grouping endpoints
- CRUD: `get`, `post`, `put`, `patch`, `delete` within resource blocks
- Route params: `route_param :id, type: Integer do get do ... end end`
- Namespace nesting: `namespace :admin do resource :users do ... end end`
- Description: `desc 'List all users'` before each endpoint for documentation

### Parameter Validation
- Use `params do ... end` block for declarative parameter validation
- Required: `requires :name, type: String, desc: 'User name'`
- Optional: `optional :page, type: Integer, default: 1`
- Nested: `requires :address, type: Hash do requires :city, type: String end`
- Custom validators: `validates :email, regexp: URI::MailTo::EMAIL_REGEXP`
- Grape validates and coerces parameters automatically before the endpoint body runs

### Entity (Presenter) Patterns
- Use `Grape::Entity` for response serialization
- Define entities: `class UserEntity < Grape::Entity; expose :id, :name, :email; end`
- Conditional exposure: `expose :admin, if: :is_admin`
- Nested entities: `expose :posts, using: PostEntity`
- Present in endpoints: `present users, with: V1::Entities::User`

### Error Handling
- Use `error!('Not found', 404)` for immediate error responses
- Rescue specific exceptions: `rescue_from ActiveRecord::RecordNotFound do |e| error!('Not found', 404) end`
- Global rescue: `rescue_from :all do |e| error!('Internal error', 500) end`
- Custom error formatter: `error_formatter :json, ->(message, backtrace, options, env, original_exception) { ... }`

### Anti-Patterns to Avoid
- Do not put business logic in endpoint blocks — extract to service objects
- Do not skip parameter validation — Grape's DSL makes it straightforward
- Do not return raw ActiveRecord objects — use Grape entities for serialization
- Do not define all endpoints in one class — split by resource
- Do not forget to set `format :json` — Grape defaults to no content negotiation
