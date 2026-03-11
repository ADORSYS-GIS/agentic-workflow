## SwiftUI Conventions

### Project Structure
- Group by feature: `Features/{Feature}/Views/`, `Features/{Feature}/ViewModels/`, `Features/{Feature}/Models/`
- Shared views: `Components/` for reusable UI components
- Navigation: `Navigation/` for router and coordinator patterns
- Services: `Services/` for networking, persistence, and business logic
- Resources: `Resources/` for assets, colors, and localizations
- App entry: `{App}App.swift` with `@main` and `WindowGroup`

### View Patterns
- Keep views small and focused — extract subviews when a view exceeds 50 lines of body
- Use `@ViewBuilder` for conditional view composition
- Prefer composition over large switch statements in view bodies
- Name views by what they display: `UserProfileView`, `OrderSummaryCard`
- Use `#Preview` macro (Xcode 15+) for previews: `#Preview { UserProfileView(user: .preview) }`
- Provide `.preview` static properties on models for preview data

### State Management
- `@State`: local, value-type state owned by the view
- `@Binding`: child view reference to parent's `@State`
- `@StateObject`: owns an `ObservableObject`; creates it once when the view appears
- `@ObservedObject`: references an `ObservableObject` owned elsewhere
- `@EnvironmentObject`: shared state injected into the environment
- `@Observable` macro (iOS 17+): preferred over `ObservableObject` — simpler, more performant

### MVVM Pattern
- ViewModels: `@Observable class UserProfileViewModel { ... }` (iOS 17+) or `ObservableObject`
- Views own ViewModels via `@State` (not `@StateObject` with `@Observable`)
- ViewModels contain business logic, data fetching, and state transformations
- Views should not contain logic beyond simple formatting and conditional rendering
- Inject services into ViewModels via constructor for testability

### Navigation
- Use `NavigationStack` with `navigationDestination(for:)` for type-safe navigation (iOS 16+)
- Use `NavigationPath` for programmatic navigation control
- Define `Hashable` route types for each navigation destination
- Use `sheet`, `fullScreenCover`, `alert` modifiers for modal presentation
- Avoid deep nesting of `NavigationLink` — use coordinator or router patterns

### Performance
- Use `LazyVStack`/`LazyHStack` inside `ScrollView` for large lists (not `VStack`)
- Use `List` with `id` parameter for efficient diffing
- Mark views as `@Observable` to avoid unnecessary re-renders from unrelated state changes
- Use `equatable()` modifier or `EquatableView` to prevent re-renders when props have not changed
- Cache expensive computed images with `.task { }` and `@State`

### Anti-Patterns to Avoid
- Do not use `@ObservedObject` to create objects — use `@StateObject` or `@State` (the view does not own it)
- Do not force-unwrap optionals in views — use `if let` or provide defaults
- Do not perform heavy computation in view `body` — move to ViewModel or use `.task { }`
- Do not use `@EnvironmentObject` without injecting it — crashes at runtime with no compile warning
- Do not put networking code directly in views — use ViewModels and services
