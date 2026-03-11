#!/usr/bin/env bash
# =============================================================================
# ui.sh — UI helper functions for the Agentic Workflow interactive CLI setup
# =============================================================================
# This file is meant to be sourced by setup.sh, not executed directly.
# Provides colored output, banners, step indicators, and interactive prompts.
# =============================================================================

# Guard against double-sourcing
[[ -n "${_UI_SH_LOADED:-}" ]] && return 0
readonly _UI_SH_LOADED=1

# -----------------------------------------------------------------------------
# Color Constants
# -----------------------------------------------------------------------------
# Use tput when available and the terminal supports colors; fall back to raw
# ANSI escape codes; degrade gracefully to empty strings when neither works.
# -----------------------------------------------------------------------------
_ui_init_colors() {
    if [[ -t 1 ]] && command -v tput &>/dev/null && [[ "$(tput colors 2>/dev/null || echo 0)" -ge 8 ]]; then
        GREEN="$(tput setaf 2)"
        BLUE="$(tput setaf 4)"
        YELLOW="$(tput setaf 3)"
        RED="$(tput setaf 1)"
        CYAN="$(tput setaf 6)"
        BOLD="$(tput bold)"
        RESET="$(tput sgr0)"
    elif [[ -t 1 ]]; then
        GREEN=$'\033[0;32m'
        BLUE=$'\033[0;34m'
        YELLOW=$'\033[0;33m'
        RED=$'\033[0;31m'
        CYAN=$'\033[0;36m'
        BOLD=$'\033[1m'
        RESET=$'\033[0m'
    else
        GREEN=""
        BLUE=""
        YELLOW=""
        RED=""
        CYAN=""
        BOLD=""
        RESET=""
    fi
}

_ui_init_colors

# -----------------------------------------------------------------------------
# Output Helpers
# -----------------------------------------------------------------------------

# Print a decorative welcome banner.
print_banner() {
    local border="${CYAN}============================================================${RESET}"
    printf '\n%s\n' "${border}"
    printf '  %s%sAgentic Workflow Setup%s\n' "${BOLD}" "${CYAN}" "${RESET}"
    printf '%s\n\n' "${border}"
}

# Print a colored section header with a separator line.
#   $1 — header text
print_header() {
    local text="${1:?print_header requires a header string}"
    printf '\n%s%s── %s ──%s\n\n' "${BOLD}" "${BLUE}" "${text}" "${RESET}"
}

# Print a step indicator: [current/total] description
#   $1 — current step number
#   $2 — total steps
#   $3 — description
print_step() {
    local current="${1:?print_step requires current step number}"
    local total="${2:?print_step requires total step count}"
    local desc="${3:?print_step requires a description}"
    printf '%s[%s/%s]%s %s%s%s\n' \
        "${BOLD}${CYAN}" "${current}" "${total}" "${RESET}" \
        "${BOLD}" "${desc}" "${RESET}"
}

# Print a success message (green checkmark).
#   $1 — message
print_success() {
    printf '%s[✓]%s %s\n' "${GREEN}" "${RESET}" "$1"
}

# Print an error message (red X).
#   $1 — message
print_error() {
    printf '%s[✗]%s %s\n' "${RED}" "${RESET}" "$1" >&2
}

# Print an informational message (blue info icon).
#   $1 — message
print_info() {
    printf '%s[i]%s %s\n' "${BLUE}" "${RESET}" "$1"
}

# Print a warning message (yellow warning).
#   $1 — message
print_warning() {
    printf '%s[!]%s %s\n' "${YELLOW}" "${RESET}" "$1"
}

# -----------------------------------------------------------------------------
# Interactive Prompt Helpers
# -----------------------------------------------------------------------------
# All prompt functions read from /dev/tty so they work even when stdin is
# redirected (e.g., when the script is piped into bash).
# -----------------------------------------------------------------------------

# Prompt for free-text input.
#   $1 — prompt string
#   $2 — variable name to set in the caller's scope
#   $3 — (optional) default value
prompt_text() {
    local prompt_str="${1:?prompt_text requires a prompt string}"
    local var_name="${2:?prompt_text requires a variable name}"
    local default="${3:-}"
    local input=""

    while true; do
        if [[ -n "${default}" ]]; then
            printf '%s%s%s [%s]: ' "${BOLD}${YELLOW}" "${prompt_str}" "${RESET}" "${default}"
        else
            printf '%s%s%s: ' "${BOLD}${YELLOW}" "${prompt_str}" "${RESET}"
        fi
        IFS= read -r input </dev/tty || true

        # Trim leading/trailing whitespace
        input="${input#"${input%%[![:space:]]*}"}"
        input="${input%"${input##*[![:space:]]}"}"

        # Apply default when input is empty
        if [[ -z "${input}" ]]; then
            if [[ -n "${default}" ]]; then
                input="${default}"
            else
                print_warning "Input cannot be empty. Please try again."
                continue
            fi
        fi

        break
    done

    print_success "Selected: ${CYAN}${input}${RESET}"
    printf -v "${var_name}" '%s' "${input}"
}

# Prompt for a single selection from a numbered menu.
#   $1 — prompt string
#   $2 — variable name to set in the caller's scope
#   $3 — newline-separated list of options
prompt_single() {
    local prompt_str="${1:?prompt_single requires a prompt string}"
    local var_name="${2:?prompt_single requires a variable name}"
    local options_raw="${3:?prompt_single requires a list of options}"

    # Parse options into an array
    local -a options=()
    while IFS= read -r line; do
        [[ -n "${line}" ]] && options+=("${line}")
    done <<< "${options_raw}"

    local count=${#options[@]}
    if (( count == 0 )); then
        print_error "prompt_single: no options provided."
        return 1
    fi

    # Display menu
    printf '\n%s%s%s\n' "${BOLD}${YELLOW}" "${prompt_str}" "${RESET}"
    local i
    for i in "${!options[@]}"; do
        printf '  %s%d)%s %s\n' "${CYAN}" $((i + 1)) "${RESET}" "${options[$i]}"
    done

    local choice=""
    while true; do
        printf '%sEnter choice [1-%d]%s: ' "${BOLD}" "${count}" "${RESET}"
        IFS= read -r choice </dev/tty || true

        # Trim whitespace
        choice="${choice#"${choice%%[![:space:]]*}"}"
        choice="${choice%"${choice##*[![:space:]]}"}"

        # Validate: non-empty, numeric, and in range
        if [[ -z "${choice}" ]]; then
            print_warning "Please enter a number."
            continue
        fi
        if ! [[ "${choice}" =~ ^[0-9]+$ ]]; then
            print_warning "Invalid input. Enter a number between 1 and ${count}."
            continue
        fi
        if (( choice < 1 || choice > count )); then
            print_warning "Out of range. Enter a number between 1 and ${count}."
            continue
        fi

        break
    done

    local selected="${options[$((choice - 1))]}"
    print_success "Selected: ${CYAN}${selected}${RESET}"
    printf -v "${var_name}" '%s' "${selected}"
}

# Prompt for multiple selections from a numbered menu.
#   $1 — prompt string
#   $2 — variable name to set in the caller's scope (comma-separated labels)
#   $3 — newline-separated list of options
prompt_multi() {
    local prompt_str="${1:?prompt_multi requires a prompt string}"
    local var_name="${2:?prompt_multi requires a variable name}"
    local options_raw="${3:?prompt_multi requires a list of options}"

    # Parse options into an array
    local -a options=()
    while IFS= read -r line; do
        [[ -n "${line}" ]] && options+=("${line}")
    done <<< "${options_raw}"

    local count=${#options[@]}
    if (( count == 0 )); then
        print_error "prompt_multi: no options provided."
        return 1
    fi

    # Display menu
    printf '\n%s%s%s\n' "${BOLD}${YELLOW}" "${prompt_str}" "${RESET}"
    local i
    for i in "${!options[@]}"; do
        printf '  %s%d)%s %s\n' "${CYAN}" $((i + 1)) "${RESET}" "${options[$i]}"
    done
    print_info "Enter comma-separated numbers (e.g. 1,3,5) or \"all\" to select everything."

    local raw_input=""
    while true; do
        printf '%sYour selections%s: ' "${BOLD}" "${RESET}"
        IFS= read -r raw_input </dev/tty || true

        # Trim whitespace
        raw_input="${raw_input#"${raw_input%%[![:space:]]*}"}"
        raw_input="${raw_input%"${raw_input##*[![:space:]]}"}"

        if [[ -z "${raw_input}" ]]; then
            print_warning "Please enter at least one selection."
            continue
        fi

        # Handle "all"
        if [[ "$(echo "$raw_input" | tr '[:upper:]' '[:lower:]')" == "all" ]]; then
            local all_labels=""
            for i in "${!options[@]}"; do
                [[ -n "${all_labels}" ]] && all_labels+=","
                all_labels+="${options[$i]}"
            done
            print_success "Selected: ${CYAN}${all_labels}${RESET}"
            printf -v "${var_name}" '%s' "${all_labels}"
            return 0
        fi

        # Parse comma-separated numbers
        local -a nums=()
        local valid=true
        local token
        IFS=',' read -ra nums <<< "${raw_input}"

        for token in "${nums[@]}"; do
            # Trim whitespace from each token
            token="${token#"${token%%[![:space:]]*}"}"
            token="${token%"${token##*[![:space:]]}"}"

            if [[ -z "${token}" ]]; then
                continue
            fi
            if ! [[ "${token}" =~ ^[0-9]+$ ]]; then
                print_warning "\"${token}\" is not a valid number."
                valid=false
                break
            fi
            if (( token < 1 || token > count )); then
                print_warning "\"${token}\" is out of range. Must be between 1 and ${count}."
                valid=false
                break
            fi
        done

        if [[ "${valid}" != true ]]; then
            continue
        fi

        # Build result from valid, unique selections preserving input order
        local seen_tokens=""
        local result=""
        for token in "${nums[@]}"; do
            token="${token#"${token%%[![:space:]]*}"}"
            token="${token%"${token##*[![:space:]]}"}"
            [[ -z "${token}" ]] && continue
            if [[ ! ",${seen_tokens}," == *",${token},"* ]]; then
                seen_tokens="${seen_tokens},${token}"
                [[ -n "${result}" ]] && result+=","
                result="${result}${options[$((token - 1))]}"
            fi
        done

        if [[ -z "${result}" ]]; then
            print_warning "No valid selections made. Please try again."
            continue
        fi

        print_success "Selected: ${CYAN}${result}${RESET}"
        printf -v "${var_name}" '%s' "${result}"
        return 0
    done
}
