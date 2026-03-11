## Remix Conventions

### Project Structure
- Routes: `app/routes/` using file-based routing (flat routes by default in Remix v2)
- Components: `app/components/` for shared UI components
- Models/services: `app/models/` or `app/services/` for data access and business logic
- Utilities: `app/utils/` for shared helpers
- Styles: co-locate with components or use `app/styles/` for global stylesheets
- Entry files: `app/entry.client.tsx`, `app/entry.server.tsx`, `app/root.tsx`

### Data Loading
- Use `loader` functions for GET data — runs on the server, returns data via `useLoaderData()`
- Use `action` functions for mutations (POST, PUT, DELETE) — process form submissions server-side
- Loaders and actions receive `{ request, params, context }` — extract data from `Request` object
- Return data with `json()` helper: `return json({ users }, { status: 200 })`
- Use `defer()` for streaming non-critical data with `<Await>` and `<Suspense>`

### Form Handling
- Use `<Form>` component (not HTML `<form>`) for progressive enhancement
- Forms submit to the current route's `action` by default; use `action="/other"` to target another
- Use `useNavigation()` to show loading/submitting states
- Use `useActionData()` to display validation errors returned from the action
- Prefer native form elements over controlled inputs — Remix embraces the web platform

### Routing
- Flat route convention: `routes/users._index.tsx`, `routes/users.$id.tsx`
- Layouts: `routes/users.tsx` wraps all `routes/users.*.tsx` children via `<Outlet />`
- Pathless layouts: `routes/_auth.tsx` groups routes under a shared layout without a URL segment
- Resource routes: export only `loader`/`action` (no default export) for API-like endpoints

### Error Handling
- Export `ErrorBoundary` from route modules to catch errors in loaders, actions, and rendering
- Throw `Response` objects for expected errors: `throw json({ message: 'Not found' }, { status: 404 })`
- Use `isRouteErrorResponse()` to distinguish between thrown responses and unexpected errors
- Root `ErrorBoundary` catches unhandled errors from any route

### Anti-Patterns to Avoid
- Do not use `useEffect` for data fetching — use `loader` functions
- Do not use global state management (Redux, Zustand) for server data — use `loader`/`action`
- Do not use `fetch()` in components to call your own API routes — use forms and loaders
- Do not serialize non-serializable data (functions, classes) in loaders
- Do not put secrets in client-side code — loaders run only on the server
