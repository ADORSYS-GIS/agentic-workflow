## UIKit Conventions

### Project Structure
- Group by feature: `Features/{Feature}/` with ViewController, View, ViewModel, Coordinator
- Shared views: `Views/` for reusable UI components
- Networking: `Networking/` for API clients and request models
- Models: `Models/` for domain objects and DTOs
- Extensions: `Extensions/` for UIKit and Foundation extensions
- Resources: `Resources/` for storyboards, xibs, assets, and strings
- Coordinators: `Coordinators/` for navigation flow management

### View Controller Patterns
- Keep view controllers under 200 lines — extract logic to ViewModels, child VCs, and custom views
- Use MVVM or MVP pattern: VCs handle UIKit lifecycle, ViewModels handle logic
- Use `UIViewController` containment (child VCs) for complex screen compositions
- Set up views in `viewDidLoad()`; bind data in `viewWillAppear()` or via reactive bindings
- Always call `super` in lifecycle methods: `viewDidLoad`, `viewWillAppear`, `viewDidDisappear`

### View Patterns
- Prefer programmatic layout over storyboards for reusable components
- Use Auto Layout with `NSLayoutConstraint.activate([...])` or a layout DSL (SnapKit)
- Set `translatesAutoresizingMaskIntoConstraints = false` on programmatically created views
- Use `UIStackView` for linear arrangements before creating complex constraint layouts
- Custom views: override `init(frame:)` and `required init?(coder:)` for both programmatic and IB usage

### Coordinator Pattern
- Coordinators manage navigation flow: presenting, pushing, and dismissing VCs
- Each feature has a coordinator: `AuthCoordinator`, `ProfileCoordinator`
- Coordinators hold strong references to child coordinators; VCs hold weak reference to coordinator
- Use delegate protocols or closures for communication from VC back to coordinator
- The `AppCoordinator` manages the root window and top-level flow

### Table and Collection Views
- Use `UITableViewDiffableDataSource` / `UICollectionViewDiffableDataSource` (iOS 13+)
- Use `UICollectionViewCompositionalLayout` for complex layouts (iOS 13+)
- Register cells with `register(_:forCellReuseIdentifier:)`; dequeue with generic helper
- Configure cells in `cellForRowAt` — do not perform heavy work; cells are recycled
- Use `NSDiffableDataSourceSnapshot` for animated, crash-free data updates

### Memory Management
- Use `[weak self]` in closures that capture `self` and outlive the view controller
- Use `[unowned self]` only when guaranteed the reference outlives the closure
- Break retain cycles: delegates should be `weak`, closure-based callbacks use `[weak self]`
- Use Instruments (Leaks, Allocations) to detect retain cycles and memory leaks

### Anti-Patterns to Avoid
- Do not use Massive View Controller — extract logic to ViewModels, services, and child VCs
- Do not use `viewDidLoad` for navigation logic — that belongs in coordinators
- Do not use singletons for everything — use dependency injection
- Do not force-unwrap IBOutlets if there is any chance the storyboard connection breaks
- Do not perform UI updates off the main thread — always dispatch to `DispatchQueue.main`
