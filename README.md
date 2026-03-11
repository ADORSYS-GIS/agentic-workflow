![GitHub Release](https://img.shields.io/github/v/release/ADORSYS-GIS/agentic-workflow?label=latest%20release)
![GitHub Repo stars](https://img.shields.io/github/stars/ADORSYS-GIS/agentic-workflow?style=flat)
![GitHub commit activity](https://img.shields.io/github/commit-activity/m/ADORSYS-GIS/agentic-workflow)
![Platform](https://img.shields.io/badge/platform-macOS%20%7C%20Linux%20%7C%20WSL-blue)
![Shell](https://img.shields.io/badge/shell-bash%203.2%2B-green)

# Agentic Workflow

Standardize AI agent setup across your entire team. One interactive CLI, uniform configuration for everyone.

The biggest barrier to team-wide AI adoption isn't the tools  it's the **inconsistent setup** across team members. One developer has a polished `CLAUDE.md`, another has nothing. One has MCP servers configured, another doesn't know they exist. Skills that work brilliantly for one person are invisible to the rest of the team.

**agentic-workflow** fixes this. A project lead answers 10 questions about their stack, and the script generates a complete set of configuration files that every team member gets identically  same rules, same skills, same agent capabilities.


## Supported Platforms

| Platform | Status |
|----------|--------|
| [Claude Code](https://claude.ai) | `CLAUDE.md`, `.claude/skills/`, `.claude/settings.json` |
| [Cursor](https://cursor.sh) | `.cursorrules` |
| [GitHub Copilot](https://github.com/features/copilot) | `.github/copilot-instructions.md` |
| [Windsurf](https://codeium.com/windsurf) | `.windsurfrules` |
| [Codex](https://openai.com/codex) | `.codex/instructions.md` |


## The Three Pillars

This tool generates configuration across three pillars that form a complete agentic setup:

| Pillar | Purpose | What gets generated |
|--------|---------|---------------------|
| **Project rules & skills** | Encode team conventions so the agent behaves consistently for everyone | `CLAUDE.md`, `.claude/skills/`, `.cursorrules`, etc. |
| **Knowledge files** | Give agents project-specific context to avoid hallucination | Architecture docs, API references, coding conventions |
| **MCP & tool integration** | Connect agents to external systems (GitHub, Context7, etc.) | MCP server configs, IDE settings |

**Why this works:**

- **Skills-first.** Skills are portable, platform-agnostic instruction files. Standardizing them early prevents fragmentation as team members use different IDEs or agent platforms.
- **Knowledge files are the underrated piece.** Most teams skip this. Auto-scaffolding knowledge structures means agents produce output aligned with your actual codebase from day one.
- **MCP integration as a standard.** Baking GitHub MCP, Context7, and others into the setup ensures everyone has the same agent capabilities out of the box.


## Getting Started

### Install

```bash
curl -fsSL https://raw.githubusercontent.com/ADORSYS-GIS/agentic-workflow/main/install.sh | bash
```

Alternatively, clone and run directly:

```bash
git clone https://github.com/ADORSYS-GIS/agentic-workflow.git
cd agentic-workflow
bash setup.sh
```

### Run the setup

```bash
agentic-workflow
```

The interactive questionnaire walks you through 10 questions:

| # | Question | Examples |
|---|----------|----------|
| 1 | Project name | `my-saas-app` |
| 2 | Languages | TypeScript, Python, Java, Go, Rust, ... |
| 3 | Frameworks | React, Django, Spring Boot, Axum, ... |
| 4 | Package managers | pnpm, poetry, Gradle, Cargo, ... |
| 5 | Repo structure | Monorepo or single repo |
| 6 | AI agent platforms | Claude Code, Cursor, Copilot, Windsurf, Codex |
| 7 | IDEs | VS Code, IntelliJ, Neovim |
| 8 | MCP servers | GitHub, Context7, Filesystem, PostgreSQL |
| 9 | Testing frameworks | Vitest, pytest, JUnit 5, go test, ... |
| 10 | AI-assisted workflows | PR review, testing, docs, debugging, security, refactoring |

Answers are saved to `agentic-config.conf` so you can regenerate or share with the team.

### Regenerate from config

```bash
agentic-workflow --from-config agentic-config.conf --output /path/to/project
```

Re-run generation without answering questions again  useful when updating the tool or applying the same setup to a new repo.


## What Gets Generated

```
your-project/
├── CLAUDE.md                         # Project rules (composed from language + framework templates)
├── .cursorrules                      # (if Cursor selected)
├── .github/copilot-instructions.md   # (if Copilot selected)
├── .codex/instructions.md            # (if Codex selected)
├── .windsurfrules                    # (if Windsurf selected)
├── .claude/
│   ├── skills/                       # AI workflow skills
│   │   ├── pr-review/SKILL.md
│   │   ├── testing/SKILL.md
│   │   ├── documentation/SKILL.md
│   │   ├── debugging/SKILL.md
│   │   ├── security-audit/SKILL.md
│   │   └── refactoring/SKILL.md
│   └── settings.json                 # MCP server configuration
├── docs/knowledge/                   # Project knowledge scaffolds (fill in the TODOs)
│   ├── architecture.md
│   ├── coding-conventions.md
│   ├── api-reference.md
│   └── development-setup.md
└── GETTING_STARTED.md                # Onboarding guide for team members
```

### How CLAUDE.md is composed

The generated `CLAUDE.md` isn't a static template  it's composed from fragments matched to your answers:

1. **Base rules** (always included)  git conventions, security principles, error handling, code review standards
2. **Language rules**  one section per selected language with idiomatic patterns, naming conventions, and pitfalls
3. **Framework rules**  one section per selected framework with project structure, routing, state management, and anti-patterns
4. **Testing rules**  test structure, coverage expectations, and mocking philosophy for your chosen test frameworks

A TypeScript + React + Vitest project gets a completely different `CLAUDE.md` than a Python + FastAPI + pytest project  both tailored to their stack.


## Supported Stacks

**11 languages** and **60 frameworks** across all major ecosystems:

| Language | Frameworks |
|----------|------------|
| TypeScript / JavaScript | React, Next.js, Angular, Vue, Nuxt, Svelte, SvelteKit, Express, NestJS, Fastify, Hono, Remix, Astro |
| Python | Django, Flask, FastAPI, Starlette, Litestar, Pyramid, Sanic, Tornado |
| Java | Spring Boot, Quarkus, Micronaut, Jakarta EE, Vert.x, Dropwizard, Blade |
| Kotlin | Ktor, Spring Boot (Kotlin), Exposed |
| Go | Gin, Echo, Fiber, Chi, Gorilla Mux, Buffalo, Beego |
| Rust | Axum, Actix-Web, Rocket, Warp, Tide, Poem |
| C# | ASP.NET Core, Blazor, .NET MAUI, Entity Framework |
| Ruby | Rails, Sinatra, Hanami, Grape |
| PHP | Laravel, Symfony, Slim, CodeIgniter, CakePHP |
| Swift | SwiftUI, UIKit, Vapor |


## After Setup

Once the files are generated:

1. **Review `CLAUDE.md`**  the generated rules should match your team's actual conventions. Edit anything that doesn't fit.
2. **Fill in `docs/knowledge/`**  these are scaffolds with TODO markers. Replace them with your real architecture, API docs, and conventions.
3. **Update MCP tokens**  open `.claude/settings.json` and replace placeholder tokens with real values.
4. **Share `GETTING_STARTED.md`**  distribute to every team member so they can verify their setup.
5. **Commit to your repo**  these files should live in version control so every team member gets them automatically.


## Reporting an Issue

If you believe you have discovered a defect in agentic-workflow, please open [an issue](https://github.com/ADORSYS-GIS/agentic-workflow/issues). Please provide a clear summary, description, and steps to reproduce.


## Contributing

Before contributing to agentic-workflow, please read through the codebase and existing patterns. The project is pure Bash with no external dependencies  keep it that way.

Key areas for contribution:
- New language or framework templates in `templates/claude-md/`
- New skill definitions in `templates/skills/`
- New MCP server configurations in `templates/mcp/`
- Improvements to the interactive questionnaire


## Uninstall

```bash
curl -fsSL https://raw.githubusercontent.com/ADORSYS-GIS/agentic-workflow/main/install.sh | bash -s -- --uninstall
```

Or if cloned locally:

```bash
bash install.sh --uninstall
```


## License

[MIT License](LICENSE)
