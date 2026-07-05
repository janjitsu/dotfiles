#!/bin/bash
############################
# setup/common/symlinks.sh
# Create all symlinks from dotfiles to their expected locations.
############################

set -euo pipefail

DIR=~/dotfiles
OLDDIR=~/dotfiles_old

mkdir -p "$OLDDIR"

# ——— Home directory dotfiles ———
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

# ——— PulseEffects ———
if [ -d ~/.config/PulseEffects ] && [ ! -L ~/.config/PulseEffects ]; then
    mv ~/.config/PulseEffects "$OLDDIR/"
fi
ln -sfn "$DIR/pulseeffects" ~/.config/PulseEffects
echo "→ ~/.config/PulseEffects"

# ——— Touchegg ———
mkdir -p ~/.config/touchegg
ln -sfn "$DIR/touchegg.conf" ~/.config/touchegg/touchegg.conf
echo "→ ~/.config/touchegg/touchegg.conf"

# ——— Claude ———
mkdir -p ~/.claude
ln -sf "$DIR/.claude/settings.json" ~/.claude/settings.json
echo "→ ~/.claude/settings.json"

echo ""
echo "=== Symlinks created ==="
