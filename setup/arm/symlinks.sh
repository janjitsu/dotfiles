#!/bin/bash
############################
# setup/termux/symlinks.sh
# Symlinks for Termux: home dotfiles + Neovim only.
# Skips desktop-only configs (PulseEffects, Touchegg, htop).
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

mkdir -p ~/.config/nvim
ln -sfn "$DIR/nvim/init.vim" ~/.config/nvim/init.vim
ln -sfn "$DIR/nvim/coc-settings.json" ~/.config/nvim/coc-settings.json
echo "→ ~/.config/nvim/"

mkdir -p ~/.claude
ln -sf "$DIR/.claude/settings.json" ~/.claude/settings.json
echo "→ ~/.claude/settings.json"

echo ""
echo "=== Symlinks created ==="
