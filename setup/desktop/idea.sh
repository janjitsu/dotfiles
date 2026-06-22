#!/bin/bash
############################
# setup/desktop/intellij.sh
# Download the latest IntelliJ IDEA and create a desktop entry.
#
# Installs to:   ~/apps/idea/
# Desktop entry: ~/.local/share/applications/idea.desktop
############################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$HOME/apps/idea"
DESKTOP_TEMPLATE="$SCRIPT_DIR/idea.desktop"
DESKTOP_TARGET="$HOME/.local/share/applications/idea.desktop"

echo "=== IntelliJ IDEA Setup ==="
echo ""

# ——— Step 1: Get download URL ———
echo "[1/3] Fetching latest IntelliJ IDEA release..."

DOWNLOAD_URL=$(curl -fsSL "https://data.services.jetbrains.com/products/releases?code=IIU&latest=true&type=release" \
    | python3 -c "import sys,json; print(json.load(sys.stdin)['IIU'][0]['downloads']['linux']['link'])")

VERSION=$(curl -fsSL "https://data.services.jetbrains.com/products/releases?code=IIU&latest=true&type=release" \
    | python3 -c "import sys,json; print(json.load(sys.stdin)['IIU'][0]['version'])")

echo "  → Version: $VERSION"
echo "  → URL: $DOWNLOAD_URL"

# ——— Step 2: Download and extract ———
echo ""
echo "[2/3] Downloading and installing..."

mkdir -p "$HOME/apps"

TMP_FILE=$(mktemp /tmp/intellij-XXXXXX.tar.gz)
trap "rm -f '$TMP_FILE'" EXIT

echo "  → Downloading..."
curl -L --progress-bar -o "$TMP_FILE" "$DOWNLOAD_URL"

# Remove previous install if exists
if [[ -d "$INSTALL_DIR" ]]; then
    echo "  → Removing previous installation"
    rm -rf "$INSTALL_DIR"
fi

# Extract — the tar contains a top-level folder like idea-IU-243.xxx
# We extract to a temp dir then move to the clean target path
TMP_EXTRACT=$(mktemp -d /tmp/intellij-extract-XXXXXX)
tar -xzf "$TMP_FILE" -C "$TMP_EXTRACT"

# Move the single extracted folder to the install dir
mv "$TMP_EXTRACT"/idea-* "$INSTALL_DIR"
rm -rf "$TMP_EXTRACT"

echo "  → Installed to: $INSTALL_DIR"

# ——— Step 3: Desktop entry ———
echo ""
echo "[3/3] Creating desktop entry..."

mkdir -p "$(dirname "$DESKTOP_TARGET")"

# Copy template and replace %USER% with actual user
sed "s/%USER%/$USER/g" "$DESKTOP_TEMPLATE" > "$DESKTOP_TARGET"

echo "  → Desktop entry: $DESKTOP_TARGET"

echo ""
echo "=== IntelliJ IDEA $VERSION installed ==="
echo "Run with: $INSTALL_DIR/bin/idea"
