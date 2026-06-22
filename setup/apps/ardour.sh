#!/bin/bash
############################
# setup/apps/ardour.sh
# Install Ardour from the official .run installer and symlink configs.
#
# Ardour's official binaries require a donation from ardour.org/download.html
# Download the .run file first, then run this script.
#
# Usage:
#   ./setup/apps/ardour.sh ~/Downloads/Ardour-8.6.0-x86_64-gcc5.run
#
# Installs to:   ~/apps/ardour/
# Config:        ~/.config/ardour<version>/config, ui_config → dotfiles/ardour/
# Desktop entry: ~/.local/share/applications/ardour.desktop
############################

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
INSTALL_DIR="$HOME/apps/ardour"
CONFIG_SOURCE="$DOTFILES_DIR/ardour"
DESKTOP_TEMPLATE="$SCRIPT_DIR/ardour.desktop"
DESKTOP_TARGET="$HOME/.local/share/applications/ardour.desktop"

RUN_FILE="${1:-}"

if [[ -z "$RUN_FILE" ]]; then
    echo "=== Ardour Setup ==="
    echo ""
    echo "Ardour official binaries require a donation."
    echo "1. Go to: https://ardour.org/download.html"
    echo "2. Download the Linux x86_64 .run file"
    echo "3. Run this script with the path to the .run file:"
    echo ""
    echo "   $0 ~/Downloads/Ardour-X.X.X-x86_64.run"
    echo ""
    exit 1
fi

if [[ ! -f "$RUN_FILE" ]]; then
    echo "✗ File not found: $RUN_FILE"
    exit 1
fi

echo "=== Ardour Setup ==="
echo ""

# ——— Step 1: Install from .run file ———
echo "[1/3] Installing Ardour..."

mkdir -p "$INSTALL_DIR"

# Extract version from filename (e.g. Ardour-8.6.0-x86_64-gcc5.run)
VERSION=$(basename "$RUN_FILE" | grep -oP 'Ardour-\K[0-9]+\.[0-9]+\.[0-9]+' || echo "unknown")
MAJOR_VERSION=$(echo "$VERSION" | cut -d. -f1)

echo "  → Version: $VERSION"

# Run the installer — Ardour's .run extracts itself
chmod +x "$RUN_FILE"
"$RUN_FILE" --target "$INSTALL_DIR" --noexec

# If the installer created a subdirectory, find the binary
ARDOUR_BIN=$(find "$INSTALL_DIR" -name "ardour[0-9]*" -type f -executable | head -1) || true
if [[ -z "$ARDOUR_BIN" ]]; then
    # Try running the installer normally (it may need interaction)
    echo "  → Running interactive installer..."
    "$RUN_FILE"
    ARDOUR_BIN=$(which ardour 2>/dev/null || find /opt -name "ardour[0-9]*" -type f -executable 2>/dev/null | head -1) || true
fi

echo "  → Installed to: $INSTALL_DIR"

# ——— Step 2: Symlink configs ———
echo ""
echo "[2/3] Linking preferences..."

# Ardour uses version-specific config dirs: ~/.config/ardour6, ardour8, etc.
CONFIG_TARGET="$HOME/.config/ardour${MAJOR_VERSION}"

if [[ -d "$CONFIG_SOURCE" ]]; then
    mkdir -p "$CONFIG_TARGET"

    # Symlink the preference files (not the whole dir — ardour writes other runtime files)
    for conf in config ui_config; do
        if [[ -f "$CONFIG_SOURCE/$conf" ]]; then
            if [[ -f "$CONFIG_TARGET/$conf" && ! -L "$CONFIG_TARGET/$conf" ]]; then
                mv "$CONFIG_TARGET/$conf" "$CONFIG_TARGET/${conf}.bak.$(date +%s)"
            fi
            ln -sfn "$CONFIG_SOURCE/$conf" "$CONFIG_TARGET/$conf"
            echo "  → $CONFIG_TARGET/$conf → $CONFIG_SOURCE/$conf"
        fi
    done
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
echo "=== Ardour $VERSION installed ==="
