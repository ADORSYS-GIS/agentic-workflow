## React Conventions

### Project Structure
- Group by feature: `features/auth/`, `features/dashboard/` — each containing components, hooks, utils, and tests
- Shared UI primitives go in `components/ui/`; shared hooks in `hooks/`
- Co-locate tests, styles, and types with their component

### Component Patterns
- Use functional components exclusively; no class components in new code
- Prefer named exports: `export function UserCard()` over `export default`
- Keep components under 150 lines; extract sub-components when complexity grows
- Use `React.memo()` only when profiling shows unnecessary re-renders, not preemptively
- Props interfaces: define with `interface Props` in the same file, not inline

### State Management
- Local state: `useState` for simple values, `useReducer` for complex state logic
- Server state: use React Query / TanStack Query — never store API responses in global state
- Global client state: use Zustand or Context for truly global UI state (theme, auth, toasts)
- Avoid prop drilling beyond 2 levels; extract a context or use composition instead

### Hooks
- Custom hooks must start with `use` and handle one concern
- Never call hooks conditionally or inside loops
- Use `useCallback` for functions passed as props to memoized children; `useMemo` for expensive computations
- Clean up effects: return a cleanup function from `useEffect` for subscriptions, timers, and listeners

### Performance
- Lazy-load routes and heavy components with `React.lazy()` and `Suspense`
- Use virtualization (react-window, tanstack-virtual) for lists over 100 items
- Avoid creating new objects/arrays in render — hoist them or memoize
- Use the React DevTools Profiler to identify bottlenecks before optimizing

### Anti-Patterns to Avoid
- Do not use `useEffect` for state derivation — compute derived values during render
- Do not sync state between components with `useEffect` — lift state up or use a shared store
- Do not put API calls in `useEffect` directly — use a data fetching library
- Avoid index as key in lists where items can be reordered, added, or removed
