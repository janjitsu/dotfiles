#!/bin/bash
############################
# desktop/hyprland/symlinks.sh
# Symlink this machine's Hyprland + Noctalia config into place.
# Standalone, manually run — not wired into setup.sh/arch.sh, since only
# this specific Hyprland box needs it.
#
# Usage:
#   ./desktop/hyprland/symlinks.sh
############################

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OLDDIR=~/dotfiles_old

mkdir -p "$OLDDIR"

# ——— Hyprland ———
# hyprland.lua + config/*.lua + xdph.conf all live under here, so the whole
# directory is symlinked as one unit.
if [ -e ~/.config/hypr ] && [ ! -L ~/.config/hypr ]; then
    mv ~/.config/hypr "$OLDDIR/"
fi
ln -sfn "$DIR/hypr" ~/.config/hypr
echo "→ ~/.config/hypr"

# ——— Noctalia ———
if [ -e ~/.config/noctalia ] && [ ! -L ~/.config/noctalia ]; then
    mv ~/.config/noctalia "$OLDDIR/"
fi
ln -sfn "$DIR/noctalia" ~/.config/noctalia
echo "→ ~/.config/noctalia"

echo ""
echo "=== Hyprland symlinks created ==="
