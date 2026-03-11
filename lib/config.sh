#!/usr/bin/env bash
# config.sh — Library for config file management
# Config format: simple key=value, sourceable by bash

set -euo pipefail

# ---------------------------------------------------------------------------
# save_config
#   Writes the current global configuration variables to the file specified
#   by CONFIG_FILE. Creates parent directories if needed.
#
#   Globals expected: CONFIG_FILE, PROJECT_NAME, LANGUAGES, FRAMEWORKS,
#     PACKAGE_MANAGERS, REPO_STRUCTURE, AGENT_PLATFORMS, IDES,
#     MCP_SERVERS, TEST_FRAMEWORKS, WORKFLOWS
# ---------------------------------------------------------------------------
save_config() {
    if [[ -z "${CONFIG_FILE:-}" ]]; then
        echo "Error: CONFIG_FILE is not set" >&2
        return 1
    fi

    local config_dir
    config_dir="$(dirname "$CONFIG_FILE")"
    if [[ ! -d "$config_dir" ]]; then
        mkdir -p "$config_dir"
    fi

    cat > "$CONFIG_FILE" <<EOF
# Agentic Workflow Configuration
# Generated: $(date '+%Y-%m-%d %H:%M:%S')
PROJECT_NAME="${PROJECT_NAME:-}"
LANGUAGES="${LANGUAGES:-}"
FRAMEWORKS="${FRAMEWORKS:-}"
PACKAGE_MANAGERS="${PACKAGE_MANAGERS:-}"
REPO_STRUCTURE="${REPO_STRUCTURE:-}"
AGENT_PLATFORMS="${AGENT_PLATFORMS:-}"
IDES="${IDES:-}"
MCP_SERVERS="${MCP_SERVERS:-}"
TEST_FRAMEWORKS="${TEST_FRAMEWORKS:-}"
WORKFLOWS="${WORKFLOWS:-}"
EOF

    return 0
}

# ---------------------------------------------------------------------------
# load_config <file_path>
#   Validates that the given file exists and sources it into the current
#   shell environment.
#
#   Arguments:
#     file_path — Path to the config file to load
#
#   Returns 1 on error (missing argument, file not found, source failure).
# ---------------------------------------------------------------------------
load_config() {
    local file_path="${1:-}"

    if [[ -z "$file_path" ]]; then
        echo "Error: load_config requires a file path argument" >&2
        return 1
    fi

    if [[ ! -f "$file_path" ]]; then
        echo "Error: Config file not found: $file_path" >&2
        return 1
    fi

    # shellcheck disable=SC1090
    if ! source "$file_path"; then
        echo "Error: Failed to source config file: $file_path" >&2
        return 1
    fi

    return 0
}

# ---------------------------------------------------------------------------
# get_config <key>
#   Echoes the value of the named configuration variable from the currently
#   loaded config (i.e., the current shell environment).
#
#   Arguments:
#     key — Variable name to look up (e.g., PROJECT_NAME)
#
#   Echoes the value or an empty string if unset.
#   Returns 1 if no key is provided.
# ---------------------------------------------------------------------------
get_config() {
    local key="${1:-}"

    if [[ -z "$key" ]]; then
        echo "Error: get_config requires a key argument" >&2
        return 1
    fi

    # Use indirect variable expansion to retrieve the value
    local value="${!key:-}"
    echo "$value"

    return 0
}
