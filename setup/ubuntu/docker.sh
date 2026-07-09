#!/bin/bash
############################
# setup/ubuntu/docker.sh
# Docker Engine via apt (official Docker repo)
############################

for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done

sudo apt update
sudo apt-get install -y ca-certificates curl gnupg

sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

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
