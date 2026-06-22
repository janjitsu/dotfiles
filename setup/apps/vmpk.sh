#!/bin/bash
############################
# setup/desktop/vmpk.sh
# Download the latest VMPK AppImage and create a desktop entry.
# Also symlinks the keymapping config from dotfiles.
#
# Installs to:   ~/apps/vmpk/
# Config:        ~/.config/vmpk.sourceforge.net/ → dotfiles/vmpk/
# Desktop entry: ~/.local/share/applications/vmpk.desktop
############################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
INSTALL_DIR="$HOME/apps/vmpk"
CONFIG_SOURCE="$DOTFILES_DIR/vmpk"
CONFIG_TARGET="$HOME/.config/vmpk.sourceforge.net"
DESKTOP_TEMPLATE="$SCRIPT_DIR/vmpk.desktop"
DESKTOP_TARGET="$HOME/.local/share/applications/vmpk.desktop"

echo "=== VMPK Setup ==="
echo ""

# ——— Step 1: Download latest AppImage from SourceForge ———
echo "[1/3] Downloading latest VMPK..."

mkdir -p "$INSTALL_DIR"

# Scrape the latest version from the SourceForge API
LATEST_VERSION=$(curl -fsSL "https://sourceforge.net/projects/vmpk/best_release.json" \
    | python3 -c "
import sys, json
data = json.load(sys.stdin)
# filename like 'vmpk/0.9.2/vmpk-0.9.2-x86_64.AppImage'
parts = data['release']['filename'].split('/')
print(parts[1])
" 2>/dev/null) || LATEST_VERSION="0.9.2"

APPIMAGE_NAME="vmpk-${LATEST_VERSION}-x86_64.AppImage"
DOWNLOAD_URL="https://sourceforge.net/projects/vmpk/files/vmpk/${LATEST_VERSION}/${APPIMAGE_NAME}/download"

echo "  → Version: $LATEST_VERSION"

if [[ -f "$INSTALL_DIR/vmpk.AppImage" ]]; then
    echo "  → Removing previous installation"
    rm -f "$INSTALL_DIR/vmpk.AppImage"
fi

curl -L --progress-bar -o "$INSTALL_DIR/vmpk.AppImage" "$DOWNLOAD_URL"
chmod +x "$INSTALL_DIR/vmpk.AppImage"

# Copy icon from current install or use a placeholder
if [[ -f "$HOME/Programs/Vmpk/vmpk.png" ]]; then
    cp "$HOME/Programs/Vmpk/vmpk.png" "$INSTALL_DIR/vmpk.png"
fi

echo "  → Installed to: $INSTALL_DIR"

# ——— Step 2: Keymapping files + config ———
echo ""
echo "[2/3] Setting up keymapping and config..."

# Symlink mapping XMLs into the install dir so the config paths resolve
if [[ -d "$CONFIG_SOURCE/mappings" ]]; then
    ln -sfn "$CONFIG_SOURCE/mappings" "$INSTALL_DIR/mappings"
    echo "  → $INSTALL_DIR/mappings → $CONFIG_SOURCE/mappings"
fi

# Resolve %USER% in config files
for conf in "$CONFIG_SOURCE"/*.conf; do
    sed -i "s/%USER%/$USER/g" "$conf"
done
echo "  → Resolved %USER% in config files"

# Symlink config directory
if [[ -d "$CONFIG_SOURCE" ]]; then
    if [[ -d "$CONFIG_TARGET" && ! -L "$CONFIG_TARGET" ]]; then
        mv "$CONFIG_TARGET" "${CONFIG_TARGET}.bak.$(date +%s)"
        echo "  → Existing config backed up"
    fi

    ln -sfn "$CONFIG_SOURCE" "$CONFIG_TARGET"
    echo "  → $CONFIG_TARGET → $CONFIG_SOURCE"
else
    echo "  ⚠  Config not found in dotfiles: $CONFIG_SOURCE"
fi

# ——— Step 3: Desktop entry ———
echo ""
echo "[3/3] Creating desktop entry..."

mkdir -p "$(dirname "$DESKTOP_TARGET")"

sed "s/%USER%/$USER/g" "$DESKTOP_TEMPLATE" > "$DESKTOP_TARGET"

echo "  → Desktop entry: $DESKTOP_TARGET"

echo ""
echo "=== VMPK $LATEST_VERSION installed ==="
echo "Run with: $INSTALL_DIR/vmpk.AppImage"
