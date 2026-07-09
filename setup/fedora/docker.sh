#!/bin/bash
############################
# setup/fedora/docker.sh
# Docker Engine via dnf (official Docker repo)
############################

sudo dnf remove -y docker \
  docker-client \
  docker-client-latest \
  docker-common \
  docker-latest \
  docker-latest-logrotate \
  docker-logrotate \
  docker-selinux \
  docker-engine-selinux \
  docker-engine

sudo dnf -y install dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo usermod -aG docker $USER
newgrp docker

sudo sh -c 'cat <<EOT > /usr/local/bin/docker-compose
#!/usr/bin/env sh

exec docker compose "\$@"
EOT
sudo chmod +x /usr/local/bin/docker-compose'

sudo systemctl start docker
sudo systemctl enable docker.service
sudo systemctl enable containerd.service
