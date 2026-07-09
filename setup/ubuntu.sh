#!/bin/bash
############################
# setup/ubuntu.sh
# Full Ubuntu setup orchestrator.
############################

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NO_DESKTOP="${NO_DESKTOP:-false}"

echo "=== Ubuntu Setup ==="

# ——— Distro packages ———
for script in "$DIR/ubuntu"/*.sh; do
    echo "→ $(basename "$script")..."
    bash "$script"
done

# ——— Desktop-only distro packages ———
if [[ "$NO_DESKTOP" == true ]]; then
    echo "→ Skipping desktop packages (--no-desktop)"
else
    for script in "$DIR/ubuntu/desktop"/*.sh; do
        echo "→ $(basename "$script")..."
        bash "$script"
    done
fi

# ——— Common steps (ordered) ———
bash "$DIR/common/zsh.sh"
bash "$DIR/common/fonts.sh"
bash "$DIR/common/symlinks.sh"
bash "$DIR/common/nvim.sh"
bash "$DIR/common/go.sh"
bash "$DIR/common/node.sh"
bash "$DIR/common/kanata.sh"
bash "$DIR/common/awscli.sh"
bash "$DIR/common/php82-docker.sh"
bash "$DIR/common/vim-plugins.sh"
bash "$DIR/common/tmux-plugins.sh"

# ——— Desktop apps ———
if [[ "$NO_DESKTOP" == true ]]; then
    echo "→ Skipping desktop apps (--no-desktop)"
else
    bash "$DIR/apps.sh"
fi

source ~/.bashrc
echo "=== Ubuntu setup complete ==="
