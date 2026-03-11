## Blazor Conventions

### Project Structure
- Components: `Components/` or `Pages/` organized by feature
- Shared components: `Components/Shared/` for reusable UI elements
- Layouts: `Components/Layout/` for page layouts (`MainLayout.razor`)
- Services: `Services/` for business logic and API clients
- Models: `Models/` for DTOs and view models
- Pages: `Components/Pages/` for routable components with `@page` directive
- wwwroot: `wwwroot/` for static files (CSS, JS, images)

### Component Patterns
- One component per `.razor` file; code-behind in `.razor.cs` for complex logic
- Use `@page "/route"` for routable page components
- Parameters: `[Parameter] public string Title { get; set; } = default!;`
- Cascading parameters: `[CascadingParameter] public Task<AuthenticationState> AuthState { get; set; }`
- Event callbacks: `[Parameter] public EventCallback<string> OnValueChanged { get; set; }`
- Render fragments: `[Parameter] public RenderFragment ChildContent { get; set; }` for composition

### Render Modes (NET 8+)
- `@rendermode InteractiveServer` — SignalR-based server interactivity
- `@rendermode InteractiveWebAssembly` — runs in browser via WebAssembly
- `@rendermode InteractiveAuto` — starts server, transitions to WASM when downloaded
- Static SSR by default (no render mode) — choose interactivity only when needed
- Apply at component or page level; propagates to child components

### State Management
- Component state: regular fields and properties in `@code { }` block
- Cross-component: inject scoped services or use cascading values
- Persistent state: use `ProtectedBrowserStorage` or `ProtectedSessionStorage`
- Server-side: DI-scoped services live for the circuit lifetime
- WASM: use in-memory state containers; persist to localStorage for durability

### Forms and Validation
- Use `EditForm` with `Model` or `EditContext` parameter
- Built-in validation: `DataAnnotationsValidator` with Data Annotations on model
- Custom validation: `FluentValidation` with a custom validator component
- Handle submit: `OnValidSubmit`, `OnInvalidSubmit`, `OnSubmit`
- Input components: `InputText`, `InputNumber`, `InputSelect`, `InputDate`

### Performance
- Use `@key` directive on list items for efficient diffing
- Avoid unnecessary re-renders: override `ShouldRender()` for pure components
- Use `StateHasChanged()` sparingly — only when external changes need to trigger re-render
- Virtualize long lists with `<Virtualize>` component
- Lazy-load assemblies for WASM with `LazyAssemblyLoader`

### Anti-Patterns to Avoid
- Do not call `StateHasChanged()` in every method — Blazor re-renders automatically after events
- Do not use `JSInterop` for things Blazor can do natively (routing, forms, DOM updates)
- Do not store large state in component parameters — use services
- Do not make synchronous HTTP calls — always use `HttpClient` with `await`
- Do not forget to dispose `IDisposable` services — implement `IDisposable` on components that subscribe to events
