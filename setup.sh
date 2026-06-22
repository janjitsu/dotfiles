#!/bin/bash
############################
# setup.sh
# Main entry point for dotfiles setup.
# Detects the distro and runs the appropriate scripts.
############################

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ——— Distro-specific packages ———
if command -v apt-get >/dev/null; then
    "$DIR/setup/ubuntu.sh"
elif command -v dnf >/dev/null; then
    "$DIR/setup/fedora.sh"
fi

# ——— Shell setup ———
chsh -s /usr/bin/zsh $USER
wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh

# Powerline fonts for gnome-terminal
git clone https://github.com/powerline/fonts.git --depth=1
./fonts/install.sh
rm -rf fonts

# ——— Symlinks ———
"$DIR/setup/symlinks.sh"

# ——— Common tools ———
"$DIR/setup/common.sh"

# ——— Vim/Neovim plugins ———
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
nvim +PlugInstall +qa

# ——— Tmux plugins ———
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
bash ~/.tmux/plugins/tpm/bin/install_plugins

# ——— Desktop apps ———
"$DIR/setup/apps.sh"

# ——— GNOME restore ———
"$DIR/backup/gnome.sh" restore

source ~/.bashrc
