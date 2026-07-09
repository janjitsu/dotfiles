#!/bin/bash
############################
# Touchegg — multi-touch gesture recognizer
############################

sudo dnf install -y touchegg

# Enable and start the daemon
sudo systemctl enable touchegg
sudo systemctl start touchegg
