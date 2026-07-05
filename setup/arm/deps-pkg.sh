#!/bin/bash
############################
# setup/arm/deps-pkg.sh
# Packages for native Termux (pkg package manager).
############################

set -euo pipefail

pkg update -y
pkg upgrade -y
pkg install -y \
    git \
    neovim \
    tmux \
    zsh \
    build-essential \
    python \
    nodejs \
    ripgrep \
    fd \
    universal-ctags \
    silversearcher-ag
