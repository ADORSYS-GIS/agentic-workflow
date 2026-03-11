## Slim Framework Conventions

### Project Structure
- Entry point: `public/index.php` creating `Slim\App` and defining routes
- Routes: `src/Routes/` or `routes/` with route group files
- Controllers (Actions): `src/Action/{Feature}/` with single-action classes
- Services: `src/Service/` for business logic
- Models: `src/Model/` for domain and database models
- Middleware: `src/Middleware/` for custom middleware
- Config: `config/` for settings, dependencies, and middleware registration

### Action (Controller) Patterns
- Use single-action invokable classes: `__invoke(Request $request, Response $response, array $args)`
- One class per endpoint action for clean separation
- Actions: parse input, call service, write response — nothing more
- Return `$response->withJson($data, 200)` or write to body with `$response->getBody()->write()`
- Use PSR-7 Request/Response interfaces throughout

### Route Patterns
- Group routes: `$app->group('/api/v1', function (RouteCollectorProxy $group) { ... })`
- Define routes: `$group->get('/users/{id}', GetUserAction::class)`
- Route placeholders: `{id:[0-9]+}` for typed path parameters
- Middleware on groups: `$group->add(new AuthMiddleware())` for auth on API routes
- Use named routes: `->setName('user.show')` for URL generation

### Dependency Injection
- Use a PSR-11 container (PHP-DI recommended): configure in `config/dependencies.php`
- Auto-wire action classes: PHP-DI resolves constructor parameters automatically
- Define factory functions for complex service construction
- Inject services via constructor in actions and middleware
- Register the container when creating the app: `AppFactory::createFromContainer($container)`

### Middleware
- PSR-15 middleware: `process(ServerRequestInterface $request, RequestHandlerInterface $handler)`
- Add globally: `$app->add(new JsonBodyParserMiddleware())`
- Add per-route or per-group for scoped middleware
- Common middleware: body parsing, CORS, authentication, error handling
- Middleware executes in LIFO order (last added runs first)

### Error Handling
- Use Slim's built-in error middleware: `$app->addErrorMiddleware(true, true, true)`
- Custom error handler: implement `ErrorHandlerInterface` for structured JSON errors
- Throw `HttpNotFoundException`, `HttpBadRequestException` for HTTP errors
- Log errors with PSR-3 logger injected into the error handler
- Disable detailed errors in production: `addErrorMiddleware(false, true, true)`

### Anti-Patterns to Avoid
- Do not define all routes in `index.php` — split into route group files
- Do not use the container as a service locator — inject dependencies via constructors
- Do not put business logic in route closures — use action classes for testability
- Do not skip input validation — Slim does not validate request data automatically
- Do not use `echo` or `die()` for responses — use PSR-7 Response object
