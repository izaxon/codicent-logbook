#!/usr/bin/env bash
# install.sh — Install the logbook CLI (plain-file log for humans and AI agents)
#
# Usage:
#   curl -fsSL https://logbook.codicent.ai/cli/install.sh | bash
#   curl -fsSL https://logbook.codicent.ai/cli/install.sh | LOGBOOK_VERSION=0.8.0 bash
#
# Installs the self-contained logbook binary from the public GitHub Releases of
# izaxon/codicent-logbook. No .NET SDK required.
#
# The repo also hosts logbook-server releases, and "latest" points at the
# server — so this script looks up the newest logbook-v* tag instead.

set -euo pipefail

REPO="izaxon/codicent-logbook"
TOOL="logbook"
MIN_BYTES=$((5 * 1024 * 1024))  # real binaries ~35MB; catch HTML/404 pages

fetch() {  # fetch <url> → stdout
  if command -v curl >/dev/null 2>&1; then curl -fsSL "$1"
  elif command -v wget >/dev/null 2>&1; then wget -qO- "$1"
  else echo "Error: neither curl nor wget found. Please install one and retry." >&2; exit 1
  fi
}

# ── Detect OS and architecture ──────────────────────────────────────────────
OS="$(uname -s)"
ARCH="$(uname -m)"

case "$OS" in
  Linux)
    case "$ARCH" in
      x86_64)  RID="linux-x64" ;;
      aarch64|arm64) RID="linux-arm64" ;;
      *) echo "Unsupported Linux architecture: $ARCH" >&2; exit 1 ;;
    esac
    INSTALL_DIR="${HOME}/.local/bin"
    ;;
  Darwin)
    case "$ARCH" in
      arm64)  RID="osx-arm64" ;;
      x86_64) RID="osx-x64" ;;
      *) echo "Unsupported macOS architecture: $ARCH" >&2; exit 1 ;;
    esac
    INSTALL_DIR="/usr/local/bin"
    ;;
  *)
    echo "Unsupported OS: $OS" >&2
    echo "For Windows, use: iwr https://logbook.codicent.ai/cli/install.ps1 | iex" >&2
    exit 1
    ;;
esac

# ── Resolve release tag ──────────────────────────────────────────────────────
if [ -n "${LOGBOOK_VERSION:-}" ]; then
  TAG="logbook-v${LOGBOOK_VERSION#v}"
else
  TAG="$(fetch "https://api.github.com/repos/${REPO}/releases?per_page=100" \
    | grep -o '"tag_name": *"logbook-v[^"]*"' \
    | head -1 | sed 's/.*"\(logbook-v[^"]*\)"/\1/' || true)"
  if [ -z "${TAG}" ]; then
    echo "ERROR: no logbook-v* release found on https://github.com/${REPO}/releases" >&2
    echo "Docs: https://logbook.codicent.ai/cli/" >&2
    exit 1
  fi
fi

ASSET="${TOOL}-${RID}"
DOWNLOAD_URL="https://github.com/${REPO}/releases/download/${TAG}/${ASSET}"
DEST="${INSTALL_DIR}/${TOOL}"

# ── Download ─────────────────────────────────────────────────────────────────
echo "Detected: ${OS} / ${ARCH} → ${RID}"
echo "Downloading ${ASSET} (${TAG}) from GitHub Releases..."
echo "  ${DOWNLOAD_URL}"

mkdir -p "${INSTALL_DIR}"
TMP="$(mktemp)"
trap 'rm -f "${TMP}"' EXIT

if ! fetch "${DOWNLOAD_URL}" > "${TMP}"; then
  echo "" >&2
  echo "ERROR: download failed for ${DOWNLOAD_URL}" >&2
  echo "Check https://github.com/${REPO}/releases/tag/${TAG}" >&2
  exit 1
fi

SIZE="$(wc -c < "${TMP}" | tr -d ' ')"
if [ "${SIZE}" -lt "${MIN_BYTES}" ]; then
  echo "" >&2
  echo "ERROR: downloaded file is only ${SIZE} bytes (expected ~35 MB binary)." >&2
  echo "  The release asset is missing or the URL returned an error page." >&2
  echo "  URL: ${DOWNLOAD_URL}" >&2
  exit 1
fi

mv "${TMP}" "${DEST}"
trap - EXIT
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

echo "Installed: ${DEST} (${TAG}, $(awk "BEGIN{printf \"%.1f\", ${SIZE}/1048576}") MB)"
echo ""
echo "Run: logbook init"
echo "     logbook add \"my first entry #notes\""
echo "     logbook list -t notes"
echo ""
echo "See https://logbook.codicent.ai/cli/ for documentation."
