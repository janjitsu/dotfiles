#!/bin/bash
set -euo pipefail

# Requires common/symlinks.sh (or arm/symlinks.sh) to have already run:
# ~/.vim must already be the symlink to dotfiles/vim/ (so this writes
# plug.vim into the repo, not a throwaway dir), and ~/.vimrc must exist
# for nvim's init.vim to source it.
#
# go.sh and node.sh each run as their own subprocess, so their PATH
# exports don't reach this script — export the real install locations
# here so nvim can find `go`/`node` for plugin post-install hooks
# (vim-go's GoUpdateBinaries, coc.nvim's CocInstall).
export PATH="$HOME/.go/bin:$HOME/.n/bin:$PATH"

curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
nvim +PlugInstall +qa
