#!/usr/bin/env bash
# install.sh — Install logbook-server (Codicent Logbook MCP runtime)
#
# Usage:
#   curl -fsSL https://logbook.codicent.ai/install.sh | bash
#
# Installs the self-contained logbook-server binary from the latest GitHub Release.
# No .NET SDK required.

set -euo pipefail

REPO="izaxon/codicent-logbook"
TOOL="logbook-server"

# ── Detect OS and architecture ──────────────────────────────────────────────
OS="$(uname -s)"
ARCH="$(uname -m)"

case "$OS" in
  Linux)
    case "$ARCH" in
      x86_64)  RID="linux-x64" ;;
      aarch64) RID="linux-arm64" ;;
      *)
        echo "Unsupported Linux architecture: $ARCH" >&2
        exit 1
        ;;
    esac
    INSTALL_DIR="${HOME}/.local/bin"
    ;;
  Darwin)
    case "$ARCH" in
      arm64)  RID="osx-arm64" ;;
      x86_64) RID="osx-x64" ;;
      *)
        echo "Unsupported macOS architecture: $ARCH" >&2
        exit 1
        ;;
    esac
    INSTALL_DIR="/usr/local/bin"
    ;;
  *)
    echo "Unsupported OS: $OS" >&2
    echo "For Windows, use install.ps1 instead." >&2
    exit 1
    ;;
esac

ASSET="${TOOL}-${RID}"
DOWNLOAD_URL="https://github.com/${REPO}/releases/latest/download/${ASSET}"
DEST="${INSTALL_DIR}/${TOOL}"

# ── Download ─────────────────────────────────────────────────────────────────
echo "Detected: ${OS} / ${ARCH} → ${RID}"
echo "Downloading ${ASSET} from GitHub Releases..."

mkdir -p "${INSTALL_DIR}"

if command -v curl >/dev/null 2>&1; then
  curl -fsSL --progress-bar "${DOWNLOAD_URL}" -o "${DEST}"
elif command -v wget >/dev/null 2>&1; then
  wget -q --show-progress "${DOWNLOAD_URL}" -O "${DEST}"
else
  echo "Error: neither curl nor wget found. Please install one and retry." >&2
  exit 1
fi

chmod +x "${DEST}"

# ── PATH check ───────────────────────────────────────────────────────────────
if ! echo ":${PATH}:" | grep -q ":${INSTALL_DIR}:"; then
  echo ""
  echo "  ${INSTALL_DIR} is not in your PATH."
  echo "  Add this line to your shell profile (~/.bashrc, ~/.zshrc, etc.):"
  echo ""
  echo "    export PATH=\"\$PATH:${INSTALL_DIR}\""
  echo ""
fi

echo "Installed: ${DEST}"
echo ""
echo "Run: logbook-server"
echo "     logbook-server --stdio     # stdio MCP mode (for Claude Desktop)"
echo "     logbook-server --tunnel    # start Cloudflare Quick Tunnel"
echo ""
echo "See https://logbook.codicent.ai/ for documentation."
