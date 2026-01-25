#!/bin/bash

# --- Configuration ---
ZIP_URL="https://github.com/jtroo/kanata/releases/download/v1.10.1/kanata-linux-binaries-v1.10.1-x64.zip"
TARGET_DIR="$HOME/Programs/kanata"
BIN_PATH="$TARGET_DIR/kanata"
# Change this to the actual path of your .kbd file
CONFIG_PATH="$HOME/.config/kanata/config.kbd"

# --- 1. Download and Extract ---
echo "Creating directory at $TARGET_DIR..."
mkdir -p "$TARGET_DIR"
mkdir -p "$(dirname "$CONFIG_PATH")"

echo "Downloading and extracting Kanata..."
curl -L "$ZIP_URL" -o /tmp/kanata.zip
unzip -o /tmp/kanata.zip -d "$TARGET_DIR"
rm /tmp/kanata.zip

# The zip contains 'kanata' and 'kanata_w_cmd'. We want the main binary.
chmod +x "$TARGET_DIR"/*

# --- 2. Permission Setup (uinput) ---
echo "Setting up uinput permissions..."
sudo groupadd -f uinput
sudo usermod -aG input $USER
sudo usermod -aG uinput $USER

# Create udev rule
echo 'KERNEL=="uinput", GROUP="uinput", MODE="0660", OPTIONS+="static_node=uinput"' | sudo tee /etc/udev/rules.d/99-input.rules > /dev/null
sudo udevadm control --reload-rules && sudo udevadm trigger

# --- 3. Create Systemd Service ---
# Based on the hardened configuration from the GitHub discussion
echo "Creating systemd service..."

sudo tee /etc/systemd/system/kanata.service > /dev/null <<EOF
[Unit]
Description=Kanata keyboard remapper
Documentation=https://github.com/jtroo/kanata

[Service]
Type=simple
# We run as root to ensure access to all input devices as discussed
ExecStartPre=/sbin/modprobe uinput
ExecStart=$BIN_PATH --cfg $CONFIG_PATH
Restart=no

# Hardening / Security settings from the discussion
DeviceAllow=/dev/uinput rw
DeviceAllow=char-input
ProtectSystem=strict
ProtectHome=read-only
# This allows kanata to see your config file in home
BindReadOnlyPaths=$(dirname "$CONFIG_PATH")

[Install]
WantedBy=multi-user.target
EOF

# --- 4. Finalize ---
sudo systemctl daemon-reload

echo "--------------------------------------------------------"
echo "Setup complete!"
echo "1. Put your configuration file at: $CONFIG_PATH"
echo "2. Run 'sudo systemctl enable --now kanata' to start it."
echo "3. IMPORTANT: If it fails to start, REBOOT once to apply uinput permissions."
echo "--------------------------------------------------------"
