## Workflow: CI/CD

Use this section when planning, updating, or debugging continuous integration and delivery pipelines.

- Pipelines should be idempotent, fast, and cache-aware; aim for < 10 min CI on main branches.
- Enforce branch protections and required checks. Block merges on red pipelines or low test coverage.
- Separate stages: lint → build → unit tests → integration/e2e → security scans → package → deploy.
- Artifacts must be immutable and traceable to commits; include SBOM where possible.
- Prefer declarative pipeline definitions (YAML) stored in-repo. Review for secrets exposure.
- Add rollback strategies and health checks for every deploy job.
- For GitHub Actions: pin actions by commit SHA, use OIDC to cloud, avoid long‑lived secrets.

Checklist
- Linting and type checks run early and fail fast
- Test matrix covers supported OS/versions/runtimes
- Caches scoped correctly; cache keys include lockfiles
- Build artifacts signed or checksummed
- Environments (dev/stage/prod) use the same artifact
- Deployment is atomic and reversible (blue/green, canary, or rolling)
