## Workflow: Infrastructure as Code (IaC)

Principles
- Declarative definitions, versioned in Git; changes via pull requests with review.
- Immutable infrastructure where possible; avoid snowflake servers.
- Idempotent plans and applies; no drift. Run `plan` on every PR, `apply` on protected branches.
- Separate state per environment; lock state and enable remote backends with encryption.
- Tag and document all resources with owner, environment, and purpose.

Guidance
- Terraform: pin provider versions, use modules, validate and format. Run `terraform validate` and `terraform fmt -check` in CI.
- Helm: keep values minimal per env, prefer charts over imperative `kubectl` manifests; lint charts.
- Ansible: roles > playbooks; no secrets in vars; idempotent tasks; `--check` friendly.
- Policy-as-code: use OPA/Conftest/Checkov where possible; fail builds on violations.

Checklist
- Plans are attached to PRs as artifacts/comments
- State backends are configured with locking and encryption
- Secrets are referenced via secure stores (e.g., Vault, SSM, Secrets Manager)
- Resource names and tags follow conventions
- Rollback documented (e.g., previous module version, Helm rollback)
