#!/bin/bash
############################
# setup/arch/docker.sh
# Docker via pacman — no custom repo/keyring dance needed on Arch
############################

sudo pacman -S --noconfirm docker docker-compose

sudo usermod -aG docker "$USER"
newgrp docker

sudo systemctl enable docker.service
sudo systemctl start docker.service
