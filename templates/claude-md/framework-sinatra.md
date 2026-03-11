## Sinatra Conventions

### Project Structure
- Entry point: `app.rb` or `config.ru` with Rack configuration
- Modular style: subclass `Sinatra::Base` for larger applications
- Routes: `routes/{resource}.rb` or grouped in the main app file for small projects
- Models: `models/` using ActiveRecord, Sequel, or ROM
- Services: `services/` for business logic
- Views: `views/` with ERB, Haml, or Slim templates
- Helpers: `helpers/` for shared route helper methods
- Config: `config/` for environment and database configuration

### Route Patterns
- Define routes: `get '/users/:id' do ... end`
- HTTP methods: `get`, `post`, `put`, `patch`, `delete`, `options`
- Route params: `params[:id]` or `params['id']` for path and query parameters
- Pattern matching: `get '/users/:id' do |id| ... end` with block parameters
- Halt execution: `halt 404, json(error: 'Not found')` for early returns
- Before/after filters: `before { authenticate! }`, `after { log_request }`

### Modular Application
- Use `Sinatra::Base` for mountable, testable applications
- Register extensions: `register Sinatra::Namespace` for route namespacing
- Helpers: `helpers AuthHelper` for shared methods available in routes
- Mount in `config.ru`: `map('/api') { run ApiApp }` for multiple apps
- Use `Sinatra::Namespace` for grouping: `namespace '/api/v1' do ... end`

### Request and Response
- Access JSON body: `JSON.parse(request.body.read)` or use `sinatra-contrib` for `json_params`
- Content type: `content_type :json` before returning JSON responses
- JSON response: `json(data: users)` with `sinatra/json` from sinatra-contrib
- Status code: `status 201` before the response body
- Headers: `headers 'X-Custom' => 'value'`

### Database Integration
- Use ActiveRecord with `sinatra-activerecord` gem for migrations and model integration
- Or use Sequel for a lighter ORM: `DB = Sequel.connect(DATABASE_URL)`
- Run migrations: `rake db:migrate` with `sinatra-activerecord`
- Configure per-environment: `set :database, ENV['DATABASE_URL']`
- Use connection pooling for production deployments

### Error Handling
- Define error handlers: `error 404 do json(error: 'Not found') end`
- Custom exceptions: `error MyCustomError do |e| status 422; json(error: e.message) end`
- Not found handler: `not_found do json(error: 'Route not found') end`
- Use `halt` for immediate response termination with status and body

### Anti-Patterns to Avoid
- Do not use classic (top-level) style for applications larger than a few routes — use modular
- Do not put business logic in route handlers — extract to service objects
- Do not skip input validation — Sinatra does not validate parameters automatically
- Do not forget `content_type :json` for JSON APIs — default is `text/html`
- Do not use global variables for state — use settings or dependency injection
