## Astro Conventions

### Project Structure
- Pages: `src/pages/` — file-based routing, generates one HTML page per file
- Components: `src/components/` for Astro and framework components (React, Vue, Svelte)
- Layouts: `src/layouts/` for shared page layouts (header, footer, navigation)
- Content: `src/content/` with content collections for Markdown/MDX and typed schemas
- Styles: `src/styles/` for global CSS; component-scoped styles in `<style>` tags
- API routes: `src/pages/api/` for server endpoints (SSR mode only)

### Component Patterns
- Use `.astro` components by default — they render to zero JavaScript
- Use framework components (React, Vue, Svelte) only when client-side interactivity is needed
- Client directives: `client:load` (immediately), `client:idle` (on idle), `client:visible` (on scroll)
- Pass data to components via props in the frontmatter (`---`) section
- Use `<slot />` for composition; named slots with `<slot name="header" />`

### Content Collections
- Define collections in `src/content/config.ts` with Zod schemas for type-safe frontmatter
- Query collections with `getCollection()` and `getEntry()` from `astro:content`
- Use `[...slug].astro` dynamic routes with `getStaticPaths()` to generate pages from collections
- Validate all content at build time — schema errors fail the build

### Data Fetching
- Fetch data in the frontmatter (`---`) block — it runs at build time (SSG) or request time (SSR)
- Use `Astro.props` to access props passed from parent components
- Use `Astro.params` for dynamic route parameters
- Use `Astro.request` for request headers, URL, and method (SSR mode)
- Use `Astro.glob()` for importing multiple local files

### Performance
- Astro ships zero JavaScript by default — keep it that way unless interactivity is required
- Use `client:visible` for below-the-fold interactive components
- Use image optimization with `astro:assets` and the `<Image>` component
- Prefer static generation (SSG) over SSR; use SSR only for personalized or dynamic content
- Use `transition:animate` for view transitions between pages

### Anti-Patterns to Avoid
- Do not use `client:load` on every interactive component — choose the least eager directive
- Do not use framework components for static content — use Astro components (zero JS)
- Do not mix SSG and SSR without understanding which pages need which mode
- Do not import large libraries in the frontmatter if they are only needed client-side
- Do not use `set:html` with unsanitized user content — it is a raw HTML injection point
