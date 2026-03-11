## Svelte Conventions

### Project Structure
- Components: `src/lib/components/` for reusable components
- Utilities: `src/lib/utils/` for shared logic
- Types: `src/lib/types/` for shared TypeScript definitions
- Use `$lib` alias for imports from `src/lib/`
- Component files: `PascalCase.svelte`; module files: `kebab-case.ts`

### Component Patterns
- Use Svelte 5 runes (`$state`, `$derived`, `$effect`, `$props`) for new code
- Define props with `let { prop1, prop2 }: Props = $props()` (Svelte 5)
- Keep components focused on one responsibility; extract child components for complex sections
- Use `{#snippet}` blocks (Svelte 5) for reusable template fragments within a component
- Use `<svelte:component>` for dynamic component rendering

### Reactivity
- Use `$state()` for reactive local state (replaces `let` reactivity in Svelte 4)
- Use `$derived()` for computed values (replaces `$:` reactive declarations)
- Use `$effect()` sparingly — only for side effects (DOM manipulation, logging, external subscriptions)
- Deep reactivity: `$state()` makes objects/arrays deeply reactive by default
- For performance-sensitive cases, use `$state.raw()` to opt out of deep reactivity

### State Management
- Local state: runes (`$state`, `$derived`) within components
- Shared state: Svelte stores (`writable`, `readable`, `derived`) or rune-based classes
- Use context API (`setContext`/`getContext`) for dependency injection within component trees
- Keep stores small and focused on one domain concern

### Performance
- Svelte compiles away the framework — focus on algorithmic efficiency, not framework tricks
- Use `{#key}` blocks to force re-creation of components when a value changes
- Use `{#each items as item (item.id)}` with keyed each blocks for efficient list updates
- Avoid creating stores or subscriptions in loops

### Anti-Patterns to Avoid
- Do not mix Svelte 4 reactive syntax (`$:`, `export let`) with Svelte 5 runes in the same component
- Do not mutate props — emit events or use bindable props
- Do not use `$effect` for derived state — use `$derived` instead
- Avoid two-way binding (`bind:`) on components unless the API is explicitly designed for it
