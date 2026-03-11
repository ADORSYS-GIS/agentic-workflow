#!/usr/bin/env bash
set -euo pipefail

# Resolve script directory (works even if called via symlink)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source library files
source "${SCRIPT_DIR}/lib/ui.sh"
source "${SCRIPT_DIR}/lib/config.sh"
source "${SCRIPT_DIR}/lib/generate.sh"

# --- Configuration variables (populated by questionnaire or config file) ---
PROJECT_NAME=""
LANGUAGES=""
FRAMEWORKS=""
PACKAGE_MANAGERS=""
REPO_STRUCTURE=""
AGENT_PLATFORMS=""
IDES=""
MCP_SERVERS=""
TEST_FRAMEWORKS=""
WORKFLOWS=""
OUTPUT_DIR=""
CONFIG_FILE="${SCRIPT_DIR}/agentic-config.conf"

# --- Framework, package manager, and test framework maps ---
# Functions return newline-separated options for a given language.
# Compatible with Bash 3.2+ (no associative arrays).

get_frameworks_for_lang() {
  case "$1" in
    typescript|javascript) printf '%s\n' "React" "Next.js" "Angular" "Vue" "Nuxt" "Svelte" "SvelteKit" "Express" "NestJS" "Fastify" "Hono" "Remix" "Astro" ;;
    python)  printf '%s\n' "Django" "Flask" "FastAPI" "Starlette" "Litestar" "Pyramid" "Sanic" "Tornado" ;;
    java)    printf '%s\n' "Spring Boot" "Quarkus" "Micronaut" "Jakarta EE" "Vert.x" "Dropwizard" "Blade" ;;
    kotlin)  printf '%s\n' "Ktor" "Spring Boot (Kotlin)" "Exposed" ;;
    go)      printf '%s\n' "Gin" "Echo" "Fiber" "Chi" "Gorilla Mux" "Buffalo" "Beego" ;;
    rust)    printf '%s\n' "Axum" "Actix-Web" "Rocket" "Warp" "Tide" "Poem" ;;
    csharp)  printf '%s\n' "ASP.NET Core" "Blazor" ".NET MAUI" "Entity Framework" ;;
    ruby)    printf '%s\n' "Rails" "Sinatra" "Hanami" "Grape" ;;
    php)     printf '%s\n' "Laravel" "Symfony" "Slim" "CodeIgniter" "CakePHP" ;;
    swift)   printf '%s\n' "SwiftUI" "UIKit" "Vapor" ;;
  esac
}

get_package_managers_for_lang() {
  case "$1" in
    typescript|javascript) printf '%s\n' "npm" "yarn" "pnpm" "bun" ;;
    python)  printf '%s\n' "pip" "poetry" "uv" "pipenv" "conda" ;;
    java)    printf '%s\n' "Maven" "Gradle" ;;
    kotlin)  printf '%s\n' "Gradle" "Maven" ;;
    go)      printf '%s\n' "go mod" ;;
    rust)    printf '%s\n' "Cargo" ;;
    csharp)  printf '%s\n' "NuGet" "dotnet CLI" ;;
    ruby)    printf '%s\n' "Bundler" "RubyGems" ;;
    php)     printf '%s\n' "Composer" ;;
    swift)   printf '%s\n' "Swift Package Manager" "CocoaPods" ;;
  esac
}

get_test_frameworks_for_lang() {
  case "$1" in
    typescript|javascript) printf '%s\n' "Jest" "Vitest" "Mocha" "Playwright" "Cypress" ;;
    python)  printf '%s\n' "pytest" "unittest" "nose2" ;;
    java)    printf '%s\n' "JUnit 5" "TestNG" "Mockito" ;;
    kotlin)  printf '%s\n' "JUnit 5" "Kotest" "MockK" ;;
    go)      printf '%s\n' "go test" "testify" ;;
    rust)    printf '%s\n' "cargo test" "proptest" ;;
    csharp)  printf '%s\n' "xUnit" "NUnit" "MSTest" ;;
    ruby)    printf '%s\n' "RSpec" "Minitest" ;;
    php)     printf '%s\n' "PHPUnit" "Pest" ;;
    swift)   printf '%s\n' "XCTest" "Quick/Nimble" ;;
  esac
}

# --- Helper: convert display name to template filename slug ---
to_slug() {
  local name="$1"
  echo "$name" \
    | tr '[:upper:]' '[:lower:]' \
    | sed 's/ (kotlin)/-kotlin/' \
    | sed 's/asp\.net core/aspnetcore/' \
    | sed 's/\.net /dotnet/' \
    | sed 's/entity /entity/' \
    | sed 's/spring boot/spring/' \
    | sed 's/jakarta ee/jakartaee/' \
    | sed 's/gorilla mux/gorillamux/' \
    | sed 's/actix-web/actixweb/' \
    | sed 's/swift package manager/spm/' \
    | sed 's/go mod/gomod/' \
    | sed 's/dotnet cli/dotnetcli/' \
    | sed 's/junit 5/junit5/' \
    | sed 's/go test/gotest/' \
    | sed 's/cargo test/cargotest/' \
    | sed 's/quick\/nimble/quicknimble/' \
    | sed 's/next\.js/nextjs/' \
    | sed 's/vert\.x/vertx/' \
    | sed 's/[^a-z0-9-]/-/g' \
    | sed 's/--*/-/g' \
    | sed 's/^-//;s/-$//'
}

# --- Gather options filtered by selected languages ---
# $1 = getter function name (e.g., get_frameworks_for_lang)
# $2 = comma-separated language slugs
gather_options_for_languages() {
  local getter_fn="$1"
  local languages="$2"
  local seen=""
  local result=""

  IFS=',' read -ra langs <<< "$languages"
  for lang in "${langs[@]}"; do
    lang="$(echo "$lang" | xargs)"  # trim whitespace
    while IFS= read -r opt; do
      if [[ -n "$opt" && ! ",$seen," == *",$opt,"* ]]; then
        result="${result}${opt}"$'\n'
        seen="${seen},${opt}"
      fi
    done <<< "$("$getter_fn" "$lang")"
  done

  echo "$result"
}

# --- Convert multi-select display names to comma-separated slugs ---
to_slug_list() {
  local csv="$1"
  local result=""
  IFS=',' read -ra items <<< "$csv"
  for item in "${items[@]}"; do
    item="$(echo "$item" | xargs)"
    local slug
    slug="$(to_slug "$item")"
    if [[ -n "$result" ]]; then
      result="${result},${slug}"
    else
      result="$slug"
    fi
  done
  echo "$result"
}

# --- Usage ---
usage() {
  cat <<'USAGE'
Usage: setup.sh [OPTIONS]

Options:
  --from-config <path>   Skip questionnaire, generate from existing config file
  --output <path>        Output directory (default: current directory)
  --help                 Show this help message

Examples:
  bash setup.sh                                    # Interactive questionnaire
  bash setup.sh --from-config agentic-config.conf  # Regenerate from config
  bash setup.sh --output /path/to/project          # Specify output directory
USAGE
}

# --- Parse CLI arguments ---
FROM_CONFIG=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --from-config)
      FROM_CONFIG="$2"
      shift 2
      ;;
    --output)
      OUTPUT_DIR="$2"
      shift 2
      ;;
    --help)
      usage
      exit 0
      ;;
    *)
      print_error "Unknown option: $1"
      usage
      exit 1
      ;;
  esac
done

# --- Main: from config or interactive ---
if [[ -n "$FROM_CONFIG" ]]; then
  print_banner
  print_info "Loading configuration from: ${FROM_CONFIG}"
  load_config "$FROM_CONFIG"
  CONFIG_FILE="$FROM_CONFIG"
else
  print_banner
  echo ""
  print_info "This script will walk you through setting up your project's AI agent configuration."
  print_info "Your answers will be saved to a config file that can be reused or shared with the team."
  echo ""

  # ── Section 1: Project Profile ──────────────────────────────────────────
  print_header "Project Profile"

  # Q1: Project name
  print_step 1 10 "Project name"
  prompt_text "Enter your project name:" PROJECT_NAME
  echo ""

  # Q2: Languages
  print_step 2 10 "Programming languages"
  LANG_OPTIONS="TypeScript
JavaScript
Python
Java
Kotlin
Go
Rust
C#
Ruby
PHP
Swift"
  prompt_multi "Select your primary language(s):" LANGUAGES "$LANG_OPTIONS"
  # Convert to slugs for internal use
  LANGUAGES="$(to_slug_list "$LANGUAGES")"
  echo ""

  # Q3: Frameworks (filtered by languages)
  print_step 3 10 "Frameworks"
  FW_OPTIONS="$(gather_options_for_languages get_frameworks_for_lang "$LANGUAGES")"
  if [[ -n "$FW_OPTIONS" ]]; then
    prompt_multi "Select your framework(s):" FRAMEWORKS "$FW_OPTIONS"
    FRAMEWORKS="$(to_slug_list "$FRAMEWORKS")"
  else
    print_warning "No frameworks available for your selected languages."
    FRAMEWORKS=""
  fi
  echo ""

  # Q4: Package managers (filtered by languages)
  print_step 4 10 "Package managers / build tools"
  PM_OPTIONS="$(gather_options_for_languages get_package_managers_for_lang "$LANGUAGES")"
  if [[ -n "$PM_OPTIONS" ]]; then
    prompt_multi "Select your package manager(s) / build tool(s):" PACKAGE_MANAGERS "$PM_OPTIONS"
    PACKAGE_MANAGERS="$(to_slug_list "$PACKAGE_MANAGERS")"
  else
    print_warning "No package managers mapped for your selected languages."
    PACKAGE_MANAGERS=""
  fi
  echo ""

  # Q5: Repo structure
  print_step 5 10 "Repository structure"
  REPO_OPTIONS="Monorepo
Single repo"
  prompt_single "Select your repository structure:" REPO_STRUCTURE "$REPO_OPTIONS"
  REPO_STRUCTURE="$(to_slug "$REPO_STRUCTURE")"
  echo ""

  # ── Section 2: Team & Tools ─────────────────────────────────────────────
  print_header "Team & Tools"

  # Q6: AI agent platforms
  print_step 6 10 "AI agent platforms"
  PLATFORM_OPTIONS="Claude Code
Cursor
GitHub Copilot
Windsurf
Codex CLI"
  prompt_multi "Select AI agent platforms your team uses:" AGENT_PLATFORMS "$PLATFORM_OPTIONS"
  AGENT_PLATFORMS="$(to_slug_list "$AGENT_PLATFORMS")"
  echo ""

  # Q7: IDEs
  print_step 7 10 "IDEs"
  IDE_OPTIONS="VS Code
IntelliJ/JetBrains
Neovim
Other"
  prompt_multi "Select IDEs your team uses:" IDES "$IDE_OPTIONS"
  IDES="$(to_slug_list "$IDES")"
  echo ""

  # ── Section 3: Integrations & Workflows ─────────────────────────────────
  print_header "Integrations & Workflows"

  # Q8: MCP servers
  print_step 8 10 "MCP server integrations"
  MCP_OPTIONS="GitHub
Context7
Filesystem
PostgreSQL
None"
  prompt_multi "Select MCP servers to integrate:" MCP_SERVERS "$MCP_OPTIONS"
  # If "None" is selected, clear the list
  if [[ "$MCP_SERVERS" == "None" || "$MCP_SERVERS" == *"None"* ]]; then
    MCP_SERVERS=""
  else
    MCP_SERVERS="$(to_slug_list "$MCP_SERVERS")"
  fi
  echo ""

  # Q9: Testing frameworks (filtered by languages)
  print_step 9 10 "Testing frameworks"
  TF_OPTIONS="$(gather_options_for_languages get_test_frameworks_for_lang "$LANGUAGES")"
  if [[ -n "$TF_OPTIONS" ]]; then
    prompt_multi "Select your testing framework(s):" TEST_FRAMEWORKS "$TF_OPTIONS"
    TEST_FRAMEWORKS="$(to_slug_list "$TEST_FRAMEWORKS")"
  else
    print_warning "No testing frameworks mapped for your selected languages."
    TEST_FRAMEWORKS=""
  fi
  echo ""

  # Q10: Workflows
  print_step 10 10 "AI-assisted workflows"
  WF_OPTIONS="PR review
Testing
Documentation
Debugging
Security audit
Refactoring"
  prompt_multi "Select workflows to set up skills for:" WORKFLOWS "$WF_OPTIONS"
  WORKFLOWS="$(to_slug_list "$WORKFLOWS")"
  echo ""

  # ── Save config ─────────────────────────────────────────────────────────
  print_header "Saving Configuration"
  save_config
  print_success "Configuration saved to: ${CONFIG_FILE}"
  echo ""
fi

# --- Output directory ---
if [[ -z "$OUTPUT_DIR" ]]; then
  print_header "Output Directory"
  prompt_text "Where should the generated files be placed? (path):" OUTPUT_DIR "."
  echo ""
fi

# Resolve to absolute path
OUTPUT_DIR="$(cd "$OUTPUT_DIR" 2>/dev/null && pwd || echo "$OUTPUT_DIR")"

# --- Generate ---
print_header "Generating Configuration Files"
echo ""
generate_all

echo ""
print_header "Setup Complete"
echo ""
print_success "All configuration files have been generated in: ${OUTPUT_DIR}"
echo ""
print_info "Next steps:"
echo "  1. Review the generated files, especially CLAUDE.md"
echo "  2. Fill in the TODO sections in docs/knowledge/ files"
echo "  3. Update MCP server tokens in .claude/settings.json"
echo "  4. Share GETTING_STARTED.md with your team"
echo "  5. Commit the generated files to your repository"
echo ""
print_info "To regenerate from your saved config:"
echo "  bash ${SCRIPT_DIR}/setup.sh --from-config ${CONFIG_FILE}"
echo ""
