#!/usr/bin/env bash
# Install claude-squad (the `cs` binary) for this checkout.
#
# The upstream one-liner is:
#   curl -fsSL https://raw.githubusercontent.com/smtg-ai/claude-squad/main/install.sh | bash
# It downloads a prebuilt release asset from the GitHub releases API. In
# sandboxed environments where that API is unreachable, this script falls back
# to building from source with Go, which only needs plain git + the module proxy.

set -euo pipefail

VERSION="${VERSION:-v1.0.20}"
BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"
INSTALL_NAME="${INSTALL_NAME:-cs}"

log() { printf '%s\n' "$*" >&2; }

if ! command -v tmux >/dev/null 2>&1; then
  log "error: tmux is required by claude-squad but is not installed."
  log "  Debian/Ubuntu: sudo apt-get install -y tmux"
  log "  macOS:         brew install tmux"
  exit 1
fi

if ! command -v gh >/dev/null 2>&1; then
  log "warning: the GitHub CLI (gh) is not installed."
  log "claude-squad works without it, but its push/PR shortcuts will not."
fi

mkdir -p "$BIN_DIR"

# Preferred path: the official installer, when the releases API is reachable.
if curl -fsS -o /dev/null "https://api.github.com/repos/smtg-ai/claude-squad/releases" 2>/dev/null; then
  log "Installing claude-squad via the official release installer..."
  curl -fsSL https://raw.githubusercontent.com/smtg-ai/claude-squad/main/install.sh \
    | SHELL="${SHELL:-/bin/bash}" BIN_DIR="$BIN_DIR" bash -s -- --name "$INSTALL_NAME"
else
  log "GitHub releases API unreachable; building claude-squad $VERSION from source."

  if ! command -v go >/dev/null 2>&1; then
    log "error: Go is required for the source build but is not installed."
    log "See https://go.dev/dl/"
    exit 1
  fi

  src="$(mktemp -d)"
  trap 'rm -rf "$src"' EXIT

  git clone --depth 1 --branch "$VERSION" \
    https://github.com/smtg-ai/claude-squad "$src/claude-squad" >/dev/null 2>&1 \
    || git clone --depth 1 https://github.com/smtg-ai/claude-squad "$src/claude-squad"

  (cd "$src/claude-squad" && go build -o "$BIN_DIR/$INSTALL_NAME" .)
fi

log ""
log "Installed: $("$BIN_DIR/$INSTALL_NAME" version | head -1)  ->  $BIN_DIR/$INSTALL_NAME"

case ":$PATH:" in
  *":$BIN_DIR:"*) ;;
  *) log "note: $BIN_DIR is not on your PATH. Add: export PATH=\"\$PATH:$BIN_DIR\"" ;;
esac
