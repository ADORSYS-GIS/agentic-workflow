## Next.js Conventions

### Project Structure (App Router)
- Use the App Router (`app/` directory) for all new routes
- Route files: `page.tsx`, `layout.tsx`, `loading.tsx`, `error.tsx`, `not-found.tsx`
- API routes: `app/api/{resource}/route.ts` using Route Handlers
- Group related routes with route groups `(groupName)` for shared layouts without URL impact
- Place shared components in `components/`, utilities in `lib/`, types in `types/`

### Server vs Client Components
- Default to Server Components — add `'use client'` only when the component needs browser APIs, event handlers, or state
- Keep `'use client'` boundaries as low as possible in the component tree
- Never import server-only code (env vars, DB clients) in client components
- Use `server-only` package to prevent accidental client-side imports of sensitive modules

### Data Fetching
- Fetch data in Server Components using `async` functions directly — no `useEffect`
- Use `fetch()` with Next.js caching: `{ cache: 'force-cache' }` (default), `{ next: { revalidate: 60 } }`, or `{ cache: 'no-store' }`
- Mutations: use Server Actions (`'use server'` functions) for form submissions and data writes
- Use `revalidatePath()` or `revalidateTag()` after mutations to refresh cached data

### Routing
- Use file-system routing; dynamic segments with `[id]`, catch-all with `[...slug]`
- Use `generateStaticParams()` for static generation of dynamic routes
- Parallel routes (`@slot`) for modals and split layouts
- Intercepting routes (`(.)`, `(..)`) for modal patterns

### Performance
- Use `next/image` for all images — never raw `<img>` tags
- Use `next/font` for font loading to prevent layout shift
- Prefer static generation (SSG) over server-side rendering (SSR) when data does not change per-request
- Use Suspense boundaries around async components for streaming
- Minimize client-side JavaScript by keeping components on the server

### Anti-Patterns to Avoid
- Do not use the Pages Router for new features when the project uses App Router
- Do not fetch data in client components when it can be done on the server
- Do not store fetched data in `useState` — let Server Components handle it
- Do not use `getServerSideProps`/`getStaticProps` in App Router (those are Pages Router APIs)
- Do not expose secrets via `NEXT_PUBLIC_` environment variables
