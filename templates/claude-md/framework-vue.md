## Vue Conventions

### Project Structure
- Use `src/` with subdirectories: `components/`, `composables/`, `views/`, `stores/`, `router/`, `types/`
- Group by feature for larger apps: `src/features/{feature}/` with components, composables, and store
- Single-file components (`.vue`): `<script setup>` first, then `<template>`, then `<style scoped>`
- File naming: `PascalCase.vue` for components, `use-camelCase.ts` for composables

### Component Patterns
- Use `<script setup lang="ts">` (Composition API) for all new components
- Define props with `defineProps<{ title: string }>()` using TypeScript generics
- Define emits with `defineEmits<{ (e: 'update', value: string): void }>()` for type-safe events
- Keep components under 200 lines; extract composables for complex logic
- Use `v-model` with `defineModel()` (Vue 3.4+) for two-way binding

### State Management
- Local state: `ref()` for primitives, `reactive()` for objects
- Shared composable state: extract into `composables/` with `use` prefix
- Global state: Pinia stores — one store per domain concern
- Pinia stores: prefer `setup` store syntax for better TypeScript inference and composability

### Routing
- Use Vue Router with typed route definitions
- Lazy-load route components: `component: () => import('./views/UserView.vue')`
- Use navigation guards for auth checks (`beforeEach`)
- Use `<RouterView>` with named views for complex layouts

### Performance
- Use `v-once` for static content that never changes
- Use `v-memo` for expensive list items
- Use `shallowRef`/`shallowReactive` when deep reactivity is unnecessary
- Lazy-load heavy components with `defineAsyncComponent`
- Avoid `v-if` and `v-for` on the same element — wrap with `<template>`

### Anti-Patterns to Avoid
- Do not use Options API in new code when the project uses Composition API
- Do not destructure props (loses reactivity) — use `toRefs()` if needed
- Do not mutate props directly; emit events to the parent
- Do not use `this` in `<script setup>` — it does not exist
- Avoid watchers for derived state — use `computed()` instead
