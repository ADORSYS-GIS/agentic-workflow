## Angular Conventions

### Project Structure
- Follow Angular CLI default structure: `src/app/` with feature modules
- Group by feature: `src/app/features/{feature-name}/` containing component, service, model, and spec files
- Shared code in `src/app/shared/` (pipes, directives, common components)
- Core services (auth, HTTP interceptors, guards) in `src/app/core/`
- One component/service/pipe per file — enforced by Angular style guide

### Component Patterns
- Use standalone components (Angular 14+) instead of NgModules for new code
- Prefer `OnPush` change detection strategy for all components
- Use signals (Angular 16+) for reactive state instead of RxJS `BehaviorSubject` for simple cases
- Input/Output: use `input()` and `output()` signal-based APIs (Angular 17+) over decorators
- Keep templates under 50 lines; extract sub-components for complex UI sections

### State Management
- Component-local state: signals or `BehaviorSubject`
- Feature-level state: services with signals/observables scoped to the feature
- Global state: NgRx or NGXS for complex apps; simple service-based state for smaller apps
- Always unsubscribe from observables — use `takeUntilDestroyed()` or `AsyncPipe`

### Routing
- Lazy-load feature routes with `loadComponent` or `loadChildren`
- Use route guards (`canActivate`, `canMatch`) for auth and permission checks
- Use route resolvers sparingly — prefer loading states in components
- Define routes as typed constants; avoid magic strings for route paths

### Testing
- Unit test components with `TestBed`; prefer shallow tests over deep rendering
- Test services independently with injected mock dependencies
- Use `HttpClientTestingModule` for HTTP service tests
- Test observable behavior with `subscribeSpy` or marble testing for complex streams

### Anti-Patterns to Avoid
- Do not subscribe in components without cleanup — use `async` pipe or `takeUntilDestroyed`
- Do not put business logic in components — delegate to services
- Do not use `any` type in services or component interfaces
- Avoid nested subscriptions — use RxJS operators (`switchMap`, `mergeMap`, `combineLatest`)
- Do not mutate `@Input` values — treat them as immutable
