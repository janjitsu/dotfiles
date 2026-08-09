#!/bin/bash
# lact is AUR-only; CachyOS ships paru preinstalled
paru -S --noconfirm lact
sudo systemctl enable --now lactd
