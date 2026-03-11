## .NET MAUI Conventions

### Project Structure
- Single project for all platforms: `Platforms/Android/`, `Platforms/iOS/`, `Platforms/Windows/`, `Platforms/MacCatalyst/`
- Pages: `Views/` or `Pages/` for XAML pages and their code-behind
- ViewModels: `ViewModels/` following MVVM pattern
- Models: `Models/` for data models and DTOs
- Services: `Services/` for platform-agnostic business logic and API clients
- Resources: `Resources/` for images, fonts, styles, and raw assets
- Entry point: `MauiProgram.cs` with `MauiApp.CreateBuilder()`

### MVVM Pattern
- Use `CommunityToolkit.Mvvm` for `ObservableObject`, `RelayCommand`, and source generators
- ViewModels: inherit from `ObservableObject`; use `[ObservableProperty]` for bindable properties
- Commands: use `[RelayCommand]` attribute for auto-generated `ICommand` implementations
- Navigation: inject `INavigationService` or use Shell navigation with query parameters
- Do NOT reference Views from ViewModels — communicate via data binding and messaging

### XAML Patterns
- Use `x:DataType` for compiled bindings (type-safe, better performance)
- Prefer `ContentView` for reusable components; `ContentPage` for full pages
- Use `ResourceDictionary` for shared styles, colors, and templates
- Define `DataTemplate` in resources, not inline, for reusability
- Use `Shell` for navigation structure: `TabBar`, `FlyoutItem`, route-based navigation

### Dependency Injection
- Register in `MauiProgram.cs`: `builder.Services.AddTransient<MainPage>()`
- Register ViewModels and Services: `builder.Services.AddTransient<MainViewModel>()`
- Inject via constructor in ViewModels and pages
- Use `AddSingleton` for services with app-wide state (auth, settings)

### Platform-Specific Code
- Use `#if ANDROID`, `#if IOS` preprocessor directives sparingly
- Prefer `Microsoft.Maui.Essentials` APIs for cross-platform features (geolocation, camera, preferences)
- Use `partial classes` with platform-specific implementations in `Platforms/` folders
- Custom renderers / handlers: implement in `Platforms/{platform}/Handlers/`

### Performance
- Use compiled bindings (`x:DataType`) — 8-20x faster than reflection bindings
- Avoid complex layouts: minimize nesting depth in XAML
- Use `CollectionView` with `ItemTemplate`, not `ListView` (deprecated)
- Cache images with `CachedImage` or URL-based image loading
- Profile startup with `dotnet-trace` and optimize `MauiProgram.cs` registrations

### Anti-Patterns to Avoid
- Do not put business logic in code-behind — use ViewModels
- Do not reference platform-specific types in shared code — use abstractions and DI
- Do not use `Device.BeginInvokeOnMainThread` for everything — use `MainThread.InvokeOnMainThreadAsync`
- Do not create `HttpClient` instances per-request — register via `IHttpClientFactory`
- Do not ignore async/await — blocking the UI thread freezes the app
