#!/bin/bash
############################
# setup/desktop/postman.sh
# Download the latest Postman and create a desktop entry.
#
# Installs to:   ~/apps/postman/
# Desktop entry: ~/.local/share/applications/postman.desktop
############################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$HOME/apps/postman"
DESKTOP_TEMPLATE="$SCRIPT_DIR/postman.desktop"
DESKTOP_TARGET="$HOME/.local/share/applications/postman.desktop"

echo "=== Postman Setup ==="
echo ""

# ——— Step 1: Download ———
echo "[1/2] Downloading latest Postman..."

mkdir -p "$HOME/apps"

TMP_FILE=$(mktemp /tmp/postman-XXXXXX.tar.gz)
trap "rm -f '$TMP_FILE'" EXIT

curl -L --progress-bar -o "$TMP_FILE" "https://dl.pstmn.io/download/latest/linux_64"

# Remove previous install if exists
if [[ -d "$INSTALL_DIR" ]]; then
    echo "  → Removing previous installation"
    rm -rf "$INSTALL_DIR"
fi

# Extract — the tar contains a top-level Postman/ folder
TMP_EXTRACT=$(mktemp -d /tmp/postman-extract-XXXXXX)
tar -xzf "$TMP_FILE" -C "$TMP_EXTRACT"

mv "$TMP_EXTRACT"/Postman "$INSTALL_DIR"
rm -rf "$TMP_EXTRACT"

echo "  → Installed to: $INSTALL_DIR"

# ——— Step 2: Desktop entry ———
echo ""
echo "[2/2] Creating desktop entry..."

mkdir -p "$(dirname "$DESKTOP_TARGET")"

sed "s/%USER%/$USER/g" "$DESKTOP_TEMPLATE" > "$DESKTOP_TARGET"

echo "  → Desktop entry: $DESKTOP_TARGET"

echo ""
echo "=== Postman installed ==="
echo "Run with: $INSTALL_DIR/Postman"
