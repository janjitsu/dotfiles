#!/bin/bash
# Install Iosevka Nerd Font (user-local, idempotent).
set -euo pipefail

if fc-list 2>/dev/null | grep -qi "Iosevka Nerd"; then
    echo "→ Iosevka Nerd Font already installed"
    exit 0
fi

FONT_DIR="$HOME/.local/share/fonts/IosevkaNerdFont"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "→ Downloading Iosevka Nerd Font"
curl -fsSL -o "$TMP/Iosevka.tar.xz" \
    https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Iosevka.tar.xz
mkdir -p "$FONT_DIR"
tar -xJf "$TMP/Iosevka.tar.xz" -C "$FONT_DIR"
fc-cache -f "$FONT_DIR"
echo "→ Installed to $FONT_DIR"
