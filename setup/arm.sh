#!/bin/bash
############################
# setup/arm.sh
# Lean ARM setup orchestrator — covers native Termux and proot-distro containers
# (e.g. slim Ubuntu server running inside Termux on Android).
# Scope: dotfiles + Neovim + Tmux only. No desktop apps, fonts, or GNOME.
############################

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== ARM Setup ==="

bash "$DIR/arm/deps-apt.sh"
bash "$DIR/arm/symlinks.sh"
bash "$DIR/common/vim-plugins.sh"
bash "$DIR/common/tmux-plugins.sh"

echo "=== ARM setup complete ==="
