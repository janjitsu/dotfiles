#!/bin/bash
############################
# setup/arm/deps-apk.sh
# Packages for a proot-distro Alpine container on ARM.
############################

set -euo pipefail

apk update
apk upgrade
apk add \
    bash \
    git \
    neovim \
    tmux \
    zsh \
    build-base \
    python3 \
    py3-pip \
    nodejs \
    npm \
    ripgrep \
    fd \
    ctags \
    the_silver_searcher \
    curl \
    wget
