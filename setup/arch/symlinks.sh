#!/bin/bash
############################
# setup/arch/symlinks.sh
# Trimmed symlinks for the CLI/dev-tools-only Arch/CachyOS setup: home
# dotfiles + Neovim + htop (installed via 00-base.sh) + Claude settings.
# Skips PulseEffects/touchegg since neither is installed in this profile.
############################

set -euo pipefail

DIR=~/dotfiles
OLDDIR=~/dotfiles_old

mkdir -p "$OLDDIR"

FILES="bashrc shellrc zshrc bash_local bash_aliases vimrc ackrc ideavimrc vim tmux.conf tmux gitconfig gitignore"

for file in $FILES; do
    if [ -e ~/.$file ] && [ ! -L ~/.$file ]; then
        mv ~/.$file "$OLDDIR/"
    fi
    ln -sfn "$DIR/$file" ~/.$file
    echo "→ ~/.$file"
done

# ——— Neovim ———
mkdir -p ~/.config/nvim
ln -sfn "$DIR/nvim/init.vim" ~/.config/nvim/init.vim
ln -sfn "$DIR/nvim/coc-settings.json" ~/.config/nvim/coc-settings.json
echo "→ ~/.config/nvim/"

# ——— htop ———
if [ -d ~/.config/htop ] && [ ! -L ~/.config/htop ]; then
    mv ~/.config/htop "$OLDDIR/"
fi
ln -sfn "$DIR/htop" ~/.config/htop
echo "→ ~/.config/htop"

# ——— Claude ———
mkdir -p ~/.claude
ln -sf "$DIR/.claude/settings.json" ~/.claude/settings.json
echo "→ ~/.claude/settings.json"

echo ""
echo "=== Symlinks created ==="
