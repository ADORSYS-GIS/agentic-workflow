## SvelteKit Conventions

### Project Structure
- Routes: `src/routes/` with file-based routing (`+page.svelte`, `+layout.svelte`, `+server.ts`)
- Library code: `src/lib/` accessed via `$lib` alias
- API endpoints: `src/routes/api/{resource}/+server.ts`
- Params: `src/params/` for reusable parameter matchers
- Hooks: `src/hooks.server.ts` for server-side middleware (auth, logging)

### Routing and Load Functions
- Page data: `+page.server.ts` for server-side loading; `+page.ts` for universal (runs on both)
- Use `+page.server.ts` for database access, secret-dependent logic — never expose in universal load
- Return typed data from `load()` functions; access in pages via `export let data`
- Use `+layout.server.ts` for data shared across child routes (auth state, user profile)
- Error handling: throw `error(404, 'Not found')` from load functions

### Form Actions
- Use form actions (`+page.server.ts` `actions`) for mutations instead of API endpoints
- Use `enhance` action from `$app/forms` for progressive enhancement
- Validate form data on the server; return `fail(400, { errors })` for validation failures
- Use `redirect(303, '/path')` after successful mutations

### API Endpoints
- Define in `+server.ts` with exported `GET`, `POST`, `PUT`, `DELETE` functions
- Parse request body with `request.json()` or `request.formData()`
- Return responses with `json()` helper or `new Response()`
- Use hooks (`handle` in `hooks.server.ts`) for auth middleware applied to all routes

### State Management
- Page data: from load functions, accessed via `data` prop
- Client state: Svelte stores in `$lib/stores/`
- URL state: use `$page.url.searchParams` for filter/sort state
- Never use writable stores for server-fetched data — use load functions and invalidation

### Anti-Patterns to Avoid
- Do not fetch data in `onMount` when it can be loaded in `+page.server.ts`
- Do not use `+server.ts` endpoints for page data — use load functions
- Do not access `$env/static/private` variables in client-side code
- Do not use `goto()` for form submissions — use form actions with `enhance`
- Do not store auth tokens in client-side stores — use HTTP-only cookies via hooks
