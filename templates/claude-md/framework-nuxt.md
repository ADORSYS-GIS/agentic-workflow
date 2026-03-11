## Nuxt Conventions

### Project Structure
- Follow Nuxt 3 directory conventions: `pages/`, `components/`, `composables/`, `server/`, `layouts/`, `middleware/`
- Auto-imports: components from `components/`, composables from `composables/`, utilities from `utils/`
- Server API routes: `server/api/{resource}.ts` or `server/api/{resource}/[id].ts`
- Layouts: `layouts/default.vue`, `layouts/admin.vue` — applied via `definePageMeta`
- Plugins: `plugins/` for initialization code (analytics, error tracking)

### Component Patterns
- Components in `components/` are auto-imported — no explicit import needed
- Use directory-based component naming: `components/user/Avatar.vue` becomes `<UserAvatar />`
- Use `<script setup lang="ts">` for all components
- Define page metadata with `definePageMeta({ layout: 'admin', middleware: 'auth' })`

### Data Fetching
- Use `useFetch()` for SSR-compatible data fetching (auto-dedupes between server and client)
- Use `useAsyncData()` when you need to customize the cache key or transform response
- Use `$fetch()` for client-only requests or inside event handlers (not composables)
- Use `useLazyFetch()` for non-blocking data fetching that shows loading states
- Server routes: use `defineEventHandler()` and read body with `readBody()`

### Routing
- File-based routing: `pages/users/[id].vue` becomes `/users/:id`
- Use `<NuxtLink>` instead of `<a>` for client-side navigation
- Middleware in `middleware/`: named (filename) or inline via `definePageMeta`
- Route validation: use `definePageMeta({ validate: async (route) => { ... } })`

### State Management
- Use `useState()` for SSR-safe shared state (replaces Pinia for simple cases)
- Use Pinia for complex state that needs actions, getters, and DevTools integration
- Never use plain `ref()` at module scope for shared state — it breaks SSR (state leaks between requests)

### Anti-Patterns to Avoid
- Do not call `useFetch` or `useAsyncData` inside event handlers or watchers — use `$fetch` instead
- Do not import from `#imports` manually — let auto-imports handle it
- Do not use `process.client`/`process.server` — use `<ClientOnly>` component or `import.meta.client`
- Do not access Nuxt runtime config at build time — use `useRuntimeConfig()` at runtime
- Do not place API keys in `runtimeConfig.public` — they are exposed to the client
