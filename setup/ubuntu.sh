#!/bin/bash
############################
# setup/ubuntu.sh
# Full Ubuntu setup orchestrator.
############################

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== Ubuntu Setup ==="

# ——— Distro packages ———
for script in "$DIR/ubuntu"/*.sh; do
    echo "→ $(basename "$script")..."
    bash "$script"
done

# ——— Common steps (ordered) ———
bash "$DIR/common/zsh.sh"
bash "$DIR/common/fonts.sh"
bash "$DIR/common/symlinks.sh"
bash "$DIR/common/nvim.sh"
bash "$DIR/common/go.sh"
bash "$DIR/common/docker.sh"
bash "$DIR/common/node.sh"
bash "$DIR/common/kanata.sh"
bash "$DIR/common/awscli.sh"
bash "$DIR/common/ctags.sh"
bash "$DIR/common/php82-docker.sh"
bash "$DIR/common/vim-plugins.sh"
bash "$DIR/common/tmux-plugins.sh"

# ——— Desktop apps ———
bash "$DIR/apps.sh"

source ~/.bashrc
echo "=== Ubuntu setup complete ==="
