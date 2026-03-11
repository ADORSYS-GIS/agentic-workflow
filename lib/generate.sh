#!/usr/bin/env bash
# generate.sh — Library for generating output files from templates
#
# Expected globals:
#   SCRIPT_DIR   — Root of the agentic-workflow project (where setup.sh lives)
#   OUTPUT_DIR   — Destination directory for generated files
#   PROJECT_NAME, LANGUAGES, FRAMEWORKS, PACKAGE_MANAGERS,
#   TEST_FRAMEWORKS, REPO_STRUCTURE, AGENT_PLATFORMS, IDES,
#   MCP_SERVERS, WORKFLOWS

set -euo pipefail

# ---------------------------------------------------------------------------
# Internal helpers — provide print_info / print_success / print_error if the
# calling script has not already defined them.
# ---------------------------------------------------------------------------
if ! declare -f print_info >/dev/null 2>&1; then
    print_info()    { echo "[INFO]    $*"; }
fi
if ! declare -f print_success >/dev/null 2>&1; then
    print_success() { echo "[SUCCESS] $*"; }
fi
if ! declare -f print_error >/dev/null 2>&1; then
    print_error()   { echo "[ERROR]   $*" >&2; }
fi

# ---------------------------------------------------------------------------
# _sed_inplace <expression> <file>
#   Portable in-place sed that works on both macOS and Linux.
# ---------------------------------------------------------------------------
_sed_inplace() {
    local expr="$1"
    local file="$2"

    if [[ "$(uname -s)" == "Darwin" ]]; then
        sed -i '' "$expr" "$file"
    else
        sed -i "$expr" "$file"
    fi
}

# ---------------------------------------------------------------------------
# replace_placeholders <file>
#   Replaces all {{PLACEHOLDER}} tokens in the given file with their
#   corresponding variable values.  Operates in-place.
# ---------------------------------------------------------------------------
replace_placeholders() {
    local file="${1:-}"

    if [[ -z "$file" || ! -f "$file" ]]; then
        return 0
    fi

    # Use pipe-delimited sed to avoid conflicts with slashes in values.
    # Escape pipe characters in values to prevent sed breakage.
    local safe_project_name safe_languages safe_frameworks
    local safe_package_managers safe_test_frameworks safe_repo_structure

    safe_project_name="$(echo "${PROJECT_NAME:-}" | sed 's/|/\\|/g')"
    safe_languages="$(echo "${LANGUAGES:-}" | sed 's/|/\\|/g')"
    safe_frameworks="$(echo "${FRAMEWORKS:-}" | sed 's/|/\\|/g')"
    safe_package_managers="$(echo "${PACKAGE_MANAGERS:-}" | sed 's/|/\\|/g')"
    safe_test_frameworks="$(echo "${TEST_FRAMEWORKS:-}" | sed 's/|/\\|/g')"
    safe_repo_structure="$(echo "${REPO_STRUCTURE:-}" | sed 's/|/\\|/g')"

    _sed_inplace "s|{{PROJECT_NAME}}|${safe_project_name}|g" "$file"
    _sed_inplace "s|{{LANGUAGES}}|${safe_languages}|g" "$file"
    _sed_inplace "s|{{FRAMEWORKS}}|${safe_frameworks}|g" "$file"
    _sed_inplace "s|{{PACKAGE_MANAGERS}}|${safe_package_managers}|g" "$file"
    _sed_inplace "s|{{TEST_FRAMEWORKS}}|${safe_test_frameworks}|g" "$file"
    _sed_inplace "s|{{REPO_STRUCTURE}}|${safe_repo_structure}|g" "$file"
}

# ---------------------------------------------------------------------------
# generate_claude_md
#   Composes CLAUDE.md at $OUTPUT_DIR/CLAUDE.md from template fragments.
# ---------------------------------------------------------------------------
generate_claude_md() {
    local template_dir="${SCRIPT_DIR}/templates/claude-md"
    local output_file="${OUTPUT_DIR}/CLAUDE.md"

    # Start with base template
    if [[ ! -f "${template_dir}/base.md" ]]; then
        print_error "Base template not found: ${template_dir}/base.md"
        return 1
    fi

    cp "${template_dir}/base.md" "$output_file"

    # Append language-specific fragments
    if [[ -n "${LANGUAGES:-}" ]]; then
        local lang
        IFS=',' read -ra _langs <<< "$LANGUAGES"
        for lang in "${_langs[@]}"; do
            lang="$(echo "$lang" | xargs)"  # trim whitespace
            if [[ -n "$lang" && -f "${template_dir}/lang-${lang}.md" ]]; then
                echo "" >> "$output_file"
                cat "${template_dir}/lang-${lang}.md" >> "$output_file"
            fi
        done
    fi

    # Append framework-specific fragments
    if [[ -n "${FRAMEWORKS:-}" ]]; then
        local fw
        IFS=',' read -ra _frameworks <<< "$FRAMEWORKS"
        for fw in "${_frameworks[@]}"; do
            fw="$(echo "$fw" | xargs)"
            if [[ -n "$fw" && -f "${template_dir}/framework-${fw}.md" ]]; then
                echo "" >> "$output_file"
                cat "${template_dir}/framework-${fw}.md" >> "$output_file"
            fi
        done
    fi

    # Append testing workflow fragment if selected
    if [[ -n "${WORKFLOWS:-}" ]]; then
        local wf
        IFS=',' read -ra _workflows <<< "$WORKFLOWS"
        for wf in "${_workflows[@]}"; do
            wf="$(echo "$wf" | xargs)"
            if [[ "$wf" == "testing" && -f "${template_dir}/workflow-testing.md" ]]; then
                echo "" >> "$output_file"
                cat "${template_dir}/workflow-testing.md" >> "$output_file"
            fi
        done
    fi

    replace_placeholders "$output_file"
}

# ---------------------------------------------------------------------------
# generate_skills
#   Copies skill directories from templates/skills/ to
#   $OUTPUT_DIR/.claude/skills/ for each selected workflow.
# ---------------------------------------------------------------------------
generate_skills() {
    local template_dir="${SCRIPT_DIR}/templates/skills"
    local skills_output="${OUTPUT_DIR}/.claude/skills"

    if [[ -z "${WORKFLOWS:-}" ]]; then
        return 0
    fi

    local wf
    IFS=',' read -ra _workflows <<< "$WORKFLOWS"
    for wf in "${_workflows[@]}"; do
        wf="$(echo "$wf" | xargs)"
        if [[ -z "$wf" ]]; then
            continue
        fi

        local skill_src="${template_dir}/${wf}"
        if [[ -f "${skill_src}/SKILL.md" ]]; then
            local skill_dest="${skills_output}/${wf}"
            mkdir -p "$skill_dest"
            cp -R "${skill_src}/"* "$skill_dest/"

            # Run replace_placeholders on each copied SKILL.md
            if [[ -f "${skill_dest}/SKILL.md" ]]; then
                replace_placeholders "${skill_dest}/SKILL.md"
            fi
        fi
    done
}

# ---------------------------------------------------------------------------
# generate_mcp_config
#   Composes $OUTPUT_DIR/.claude/settings.json from MCP server fragments.
# ---------------------------------------------------------------------------
generate_mcp_config() {
    local template_dir="${SCRIPT_DIR}/templates/mcp"
    local output_file="${OUTPUT_DIR}/.claude/settings.json"

    mkdir -p "${OUTPUT_DIR}/.claude"

    if [[ -z "${MCP_SERVERS:-}" ]]; then
        # Write a minimal valid settings file
        cat > "$output_file" <<'EOF'
{
  "mcpServers": {}
}
EOF
        return 0
    fi

    local servers
    IFS=',' read -ra servers <<< "$MCP_SERVERS"

    # Build the JSON content
    local json_content=""
    local first=true
    local server

    for server in "${servers[@]}"; do
        server="$(echo "$server" | xargs)"
        if [[ -z "$server" ]]; then
            continue
        fi

        local fragment_file="${template_dir}/${server}.json"
        if [[ ! -f "$fragment_file" ]]; then
            print_info "MCP fragment not found, skipping: ${fragment_file}"
            continue
        fi

        local fragment
        fragment="$(cat "$fragment_file")"

        if [[ "$first" == true ]]; then
            json_content="${fragment}"
            first=false
        else
            json_content="${json_content},
${fragment}"
        fi
    done

    cat > "$output_file" <<EOF
{
  "mcpServers": {
${json_content}
  }
}
EOF
}

# ---------------------------------------------------------------------------
# generate_knowledge
#   Copies all files from templates/knowledge/ to $OUTPUT_DIR/docs/knowledge/
#   and runs replace_placeholders on each file.
# ---------------------------------------------------------------------------
generate_knowledge() {
    local template_dir="${SCRIPT_DIR}/templates/knowledge"
    local knowledge_output="${OUTPUT_DIR}/docs/knowledge"

    if [[ ! -d "$template_dir" ]]; then
        return 0
    fi

    # Check if the knowledge directory has any files
    local file_count
    file_count="$(find "$template_dir" -maxdepth 1 -type f 2>/dev/null | wc -l | xargs)"
    if [[ "$file_count" -eq 0 ]]; then
        return 0
    fi

    mkdir -p "$knowledge_output"
    cp "${template_dir}"/* "$knowledge_output/"

    # Run replace_placeholders on each copied file
    local file
    for file in "${knowledge_output}"/*; do
        if [[ -f "$file" ]]; then
            replace_placeholders "$file"
        fi
    done
}

# ---------------------------------------------------------------------------
# generate_platform_configs
#   Copies CLAUDE.md content to platform-specific config files based on
#   AGENT_PLATFORMS selection.
# ---------------------------------------------------------------------------
generate_platform_configs() {
    local claude_md="${OUTPUT_DIR}/CLAUDE.md"

    if [[ ! -f "$claude_md" ]]; then
        print_error "CLAUDE.md not found at ${claude_md}. Run generate_claude_md first."
        return 1
    fi

    if [[ -z "${AGENT_PLATFORMS:-}" ]]; then
        return 0
    fi

    local platform
    IFS=',' read -ra _platforms <<< "$AGENT_PLATFORMS"
    for platform in "${_platforms[@]}"; do
        platform="$(echo "$platform" | xargs)"
        case "$platform" in
            claude-code)
                # CLAUDE.md is already generated, no extra action needed
                ;;
            cursor)
                cp "$claude_md" "${OUTPUT_DIR}/.cursorrules"
                ;;
            github-copilot)
                mkdir -p "${OUTPUT_DIR}/.github"
                cp "$claude_md" "${OUTPUT_DIR}/.github/copilot-instructions.md"
                ;;
            codex)
                mkdir -p "${OUTPUT_DIR}/.codex"
                cp "$claude_md" "${OUTPUT_DIR}/.codex/instructions.md"
                ;;
            windsurf)
                cp "$claude_md" "${OUTPUT_DIR}/.windsurfrules"
                ;;
            *)
                print_info "Unknown platform '${platform}', skipping."
                ;;
        esac
    done
}

# ---------------------------------------------------------------------------
# generate_getting_started
#   Generates $OUTPUT_DIR/GETTING_STARTED.md with setup guidance.
# ---------------------------------------------------------------------------
generate_getting_started() {
    local output_file="${OUTPUT_DIR}/GETTING_STARTED.md"
    local project="${PROJECT_NAME:-My Project}"

    cat > "$output_file" <<EOF
# Getting Started with {{PROJECT_NAME}}

This document describes the AI-assisted development setup generated for your project.

## Configured AI Platforms

The following AI coding platforms have been configured:

EOF

    # List configured platforms
    if [[ -n "${AGENT_PLATFORMS:-}" ]]; then
        local platform
        IFS=',' read -ra _platforms <<< "$AGENT_PLATFORMS"
        for platform in "${_platforms[@]}"; do
            platform="$(echo "$platform" | xargs)"
            case "$platform" in
                claude-code)
                    echo "- **Claude Code** -- Configuration in \`CLAUDE.md\`" >> "$output_file"
                    ;;
                cursor)
                    echo "- **Cursor** -- Configuration in \`.cursorrules\`" >> "$output_file"
                    ;;
                github-copilot)
                    echo "- **GitHub Copilot** -- Configuration in \`.github/copilot-instructions.md\`" >> "$output_file"
                    ;;
                codex)
                    echo "- **Codex** -- Configuration in \`.codex/instructions.md\`" >> "$output_file"
                    ;;
                windsurf)
                    echo "- **Windsurf** -- Configuration in \`.windsurfrules\`" >> "$output_file"
                    ;;
                *)
                    echo "- **${platform}**" >> "$output_file"
                    ;;
            esac
        done
    else
        echo "_No AI platforms were configured._" >> "$output_file"
    fi

    cat >> "$output_file" <<'EOF'

## MCP Servers

Model Context Protocol (MCP) servers extend your AI assistant with additional capabilities.

EOF

    if [[ -n "${MCP_SERVERS:-}" ]]; then
        echo "The following MCP servers have been configured:" >> "$output_file"
        echo "" >> "$output_file"

        local server
        IFS=',' read -ra _servers <<< "$MCP_SERVERS"
        for server in "${_servers[@]}"; do
            server="$(echo "$server" | xargs)"
            if [[ -n "$server" ]]; then
                echo "- **${server}**" >> "$output_file"
            fi
        done

        cat >> "$output_file" <<'EOF'

To install MCP servers, refer to each server's documentation for setup instructions.
Configuration fragments are stored in `.claude/settings.json`.
EOF
    else
        echo "_No MCP servers were configured._" >> "$output_file"
    fi

    cat >> "$output_file" <<'EOF'

## Skills

Skills are reusable prompt templates that guide the AI through specific workflows.

EOF

    if [[ -n "${WORKFLOWS:-}" ]]; then
        echo "The following skills are available:" >> "$output_file"
        echo "" >> "$output_file"

        local wf
        IFS=',' read -ra _workflows <<< "$WORKFLOWS"
        for wf in "${_workflows[@]}"; do
            wf="$(echo "$wf" | xargs)"
            if [[ -n "$wf" ]]; then
                echo "- **${wf}** -- See \`.claude/skills/${wf}/SKILL.md\` for details" >> "$output_file"
            fi
        done
    else
        echo "_No skills were configured._" >> "$output_file"
    fi

    cat >> "$output_file" <<'EOF'

## Knowledge Files

Knowledge files provide project-specific context to the AI assistant.
They are located in `docs/knowledge/`.

**Important:** These files contain placeholder content and should be updated
with your actual project details, architecture decisions, and domain knowledge.

## Verification

After setup, verify that everything is working:

1. **Check CLAUDE.md exists:**
   ```bash
   test -f CLAUDE.md && echo "CLAUDE.md is present"
   ```

2. **Check skills are in place:**
   ```bash
   ls -la .claude/skills/
   ```

3. **Check MCP configuration:**
   ```bash
   cat .claude/settings.json
   ```

4. **Test with your AI assistant:**
   Open your configured AI coding tool and verify it picks up the project instructions.

EOF

    replace_placeholders "$output_file"
}

# ---------------------------------------------------------------------------
# generate_all
#   Orchestrator that calls all generate functions in order.
# ---------------------------------------------------------------------------
generate_all() {
    if [[ -z "${OUTPUT_DIR:-}" ]]; then
        print_error "OUTPUT_DIR is not set"
        return 1
    fi

    if [[ -z "${SCRIPT_DIR:-}" ]]; then
        print_error "SCRIPT_DIR is not set"
        return 1
    fi

    # Create output directory if it doesn't exist
    if [[ ! -d "$OUTPUT_DIR" ]]; then
        mkdir -p "$OUTPUT_DIR"
        print_info "Created output directory: ${OUTPUT_DIR}"
    fi

    print_info "Generating CLAUDE.md..."
    generate_claude_md
    print_success "CLAUDE.md generated."

    print_info "Generating skills..."
    generate_skills
    print_success "Skills generated."

    print_info "Generating MCP configuration..."
    generate_mcp_config
    print_success "MCP configuration generated."

    print_info "Generating knowledge files..."
    generate_knowledge
    print_success "Knowledge files generated."

    print_info "Generating platform-specific configurations..."
    generate_platform_configs
    print_success "Platform configurations generated."

    print_info "Generating GETTING_STARTED.md..."
    generate_getting_started
    print_success "GETTING_STARTED.md generated."

    print_success "All files generated in: ${OUTPUT_DIR}"
}
