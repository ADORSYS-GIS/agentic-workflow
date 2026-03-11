#!/usr/bin/env bash
set -euo pipefail

# --- Config ---
REPO_URL="https://github.com/ADORSYS-GIS/agentic-workflow.git"
INSTALL_DIR="${HOME}/.agentic-workflow"
BIN_NAME="agentic-workflow"

# Colors (only if terminal supports them)
if [[ -t 1 ]]; then
  GREEN=$'\033[0;32m'
  RED=$'\033[0;31m'
  BLUE=$'\033[0;34m'
  BOLD=$'\033[1m'
  RESET=$'\033[0m'
else
  GREEN="" RED="" BLUE="" BOLD="" RESET=""
fi

info()    { printf '%s[i]%s %s\n' "$BLUE" "$RESET" "$1"; }
success() { printf '%s[✓]%s %s\n' "$GREEN" "$RESET" "$1"; }
error()   { printf '%s[✗]%s %s\n' "$RED" "$RESET" "$1" >&2; }

# --- Determine bin directory ---
find_bin_dir() {
  if [[ -w "/usr/local/bin" ]]; then
    echo "/usr/local/bin"
  elif [[ -d "${HOME}/.local/bin" ]]; then
    echo "${HOME}/.local/bin"
  else
    mkdir -p "${HOME}/.local/bin"
    echo "${HOME}/.local/bin"
  fi
}

# --- Uninstall ---
uninstall() {
  info "Uninstalling agentic-workflow..."

  # Find and remove symlink
  local bin_dir
  for bin_dir in "/usr/local/bin" "${HOME}/.local/bin"; do
    if [[ -L "${bin_dir}/${BIN_NAME}" ]]; then
      rm -f "${bin_dir}/${BIN_NAME}"
      success "Removed symlink: ${bin_dir}/${BIN_NAME}"
    fi
  done

  # Remove install directory
  if [[ -d "$INSTALL_DIR" ]]; then
    rm -rf "$INSTALL_DIR"
    success "Removed: ${INSTALL_DIR}"
  fi

  success "agentic-workflow has been uninstalled."
  exit 0
}

# --- Install ---
install() {
  info "Installing agentic-workflow..."

  # Check for git
  if ! command -v git &>/dev/null; then
    error "git is required but not found. Please install git first."
    exit 1
  fi

  # Remove existing installation
  if [[ -d "$INSTALL_DIR" ]]; then
    info "Removing existing installation..."
    rm -rf "$INSTALL_DIR"
  fi

  # Clone the repo
  info "Downloading agentic-workflow..."
  git clone --quiet --depth 1 "$REPO_URL" "$INSTALL_DIR"

  # Remove .git to save space (not needed for running)
  rm -rf "${INSTALL_DIR}/.git"

  # Make setup.sh executable
  chmod +x "${INSTALL_DIR}/setup.sh"

  # Create symlink
  local bin_dir
  bin_dir="$(find_bin_dir)"
  ln -sf "${INSTALL_DIR}/setup.sh" "${bin_dir}/${BIN_NAME}"

  # Read installed version
  local version="unknown"
  if [[ -f "${INSTALL_DIR}/VERSION" ]]; then
    version="$(cat "${INSTALL_DIR}/VERSION")"
  fi

  echo ""
  success "agentic-workflow v${version} installed successfully!"
  echo ""
  info "Installed to: ${INSTALL_DIR}"
  info "Command:      ${bin_dir}/${BIN_NAME}"
  echo ""

  # Check if bin_dir is in PATH
  if [[ ":${PATH}:" != *":${bin_dir}:"* ]]; then
    echo "${BOLD}NOTE:${RESET} ${bin_dir} is not in your PATH."
    echo "Add it by running:"
    echo ""
    echo "  echo 'export PATH=\"${bin_dir}:\$PATH\"' >> ~/.bashrc"
    echo "  source ~/.bashrc"
    echo ""
  fi

  info "Run ${BOLD}agentic-workflow${RESET} to get started."
  info "Run ${BOLD}agentic-workflow --help${RESET} for usage."
}

# --- Main ---
case "${1:-}" in
  --uninstall)
    uninstall
    ;;
  --help|-h)
    echo "Usage: install.sh [--uninstall | --help]"
    echo ""
    echo "Installs agentic-workflow to ~/.agentic-workflow/ and"
    echo "creates a symlink in /usr/local/bin/ (or ~/.local/bin/)."
    exit 0
    ;;
  "")
    install
    ;;
  *)
    error "Unknown option: $1"
    echo "Usage: install.sh [--uninstall | --help]"
    exit 1
    ;;
esac
