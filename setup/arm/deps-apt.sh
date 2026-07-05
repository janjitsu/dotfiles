#!/bin/bash
############################
# setup/arm/deps-apt.sh
# Packages for a proot-distro Ubuntu container on ARM.
############################

set -euo pipefail

apt-get update -y
apt-get upgrade -y
apt-get install -y \
    git \
    neovim \
    tmux \
    zsh \
    build-essential \
    python3 \
    python3-pip \
    nodejs \
    npm \
    ripgrep \
    fd-find \
    universal-ctags \
    silversearcher-ag \
    curl \
    wget
