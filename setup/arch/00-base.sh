#!/bin/bash
sudo pacman -Syu --noconfirm
sudo pacman -S --noconfirm git wget curl unzip tmux zsh htop the_silver_searcher fzf ctags lua54

# ack is AUR-only; CachyOS ships paru preinstalled
paru -S --noconfirm ack
