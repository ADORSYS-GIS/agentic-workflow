## Workflow: Containerization

Guidance
- Minimal base images; prefer distroless/ubi-micro; run as non-root; drop capabilities.
- One process per container; health checks; graceful shutdown (SIGTERM handling).
- Use multi-stage builds; cache dependencies; pin versions and verify checksums.
- Scan images for vulnerabilities in CI; fail on critical CVEs; track SBOM.
- Resource limits/requests set appropriately; avoid hostPath mounts in prod.

Checklist
- Dockerfile is multi-stage and reproducible
- User set to non-root; no hardcoded secrets
- Healthcheck defined; exposes correct ports
- Image tag follows immutable strategy (commit SHA or semver)
- Image passes vulnerability scan thresholds
