#!/bin/bash
############################
# Touchegg — multi-touch gesture recognizer
############################

sudo add-apt-repository ppa:touchegg/stable -y
sudo apt update
sudo apt install -y touchegg

# Enable and start the daemon
sudo systemctl enable touchegg
sudo systemctl start touchegg
