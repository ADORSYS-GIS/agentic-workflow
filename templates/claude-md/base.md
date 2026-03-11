# {{PROJECT_NAME}}

## Tech Stack
- **Languages:** {{LANGUAGES}}
- **Frameworks:** {{FRAMEWORKS}}
- **Package Managers:** {{PACKAGE_MANAGERS}}
- **Test Frameworks:** {{TEST_FRAMEWORKS}}

## Repository Structure
```
{{REPO_STRUCTURE}}
```

## Core Principles

- Write clean, readable code. Favor clarity over cleverness.
- Every change must leave the codebase better than you found it.
- Security is non-negotiable. Follow OWASP guidelines for all user-facing code.
- Never commit secrets, API keys, tokens, or credentials. Use environment variables and secret managers.
- All public APIs must have input validation and proper error handling.
- Prefer composition over inheritance. Favor small, focused functions.

## Git Conventions

### Commits
- Use Conventional Commits: `type(scope): description`
- Types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`
- Scope is optional but encouraged (e.g., `feat(auth): add OAuth2 flow`)
- Subject line: imperative mood, lowercase, no period, max 72 characters
- Body: explain *why* the change was made, not *what* changed (the diff shows that)

### Branches
- Feature: `feat/short-description` or `feat/TICKET-123-short-description`
- Bugfix: `fix/short-description`
- Hotfix: `hotfix/short-description`
- Release: `release/vX.Y.Z`

### Pull Requests
- PRs must have a clear description of changes and motivation
- All CI checks must pass before merge
- Require at least one approving review
- Keep PRs small and focused; split large changes into stacked PRs
- Link related issues using `Closes #123` or `Fixes #123`

## Code Review Standards

- Review for correctness, security, performance, and readability in that order
- Check for proper error handling and edge cases
- Verify test coverage for new and changed code
- Flag any hardcoded values that should be configurable
- Ensure naming is clear and consistent with the codebase
- Look for potential race conditions in concurrent code

## Error Handling Philosophy

- Fail fast and fail loudly in development; fail gracefully in production
- Use typed/structured errors, not raw strings
- Always log errors with sufficient context for debugging (timestamp, request ID, stack trace)
- Never swallow exceptions silently
- Distinguish between recoverable and unrecoverable errors
- Return meaningful error messages to API consumers (without leaking internals)

## Documentation Expectations

- Public functions and APIs must have doc comments explaining purpose, parameters, return values, and thrown errors
- Complex business logic must have inline comments explaining *why*, not *what*
- Keep README up to date when adding features, changing setup steps, or modifying architecture
- Document breaking changes prominently in changelogs
- Architecture decisions should be recorded in ADRs (Architecture Decision Records) when significant
