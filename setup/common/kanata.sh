#!/bin/bash

# --- Configuration ---
ZIP_URL="https://github.com/jtroo/kanata/releases/download/v1.10.1/kanata-linux-binaries-v1.10.1-x64.zip"
BIN_PATH="/usr/local/bin/kanata_linux_x64"
# Change this to the actual path of your .kbd file
CONFIG_PATH="$HOME/dotfiles/kanata.kbd"

# --- 1. Download and Install ---
mkdir -p "$(dirname "$CONFIG_PATH")"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

echo "Downloading and extracting Kanata..."
curl -L "$ZIP_URL" -o "$TMP_DIR/kanata.zip"
unzip -o "$TMP_DIR/kanata.zip" -d "$TMP_DIR/bin"

# The zip contains the main binary (kanata_linux_x64) plus a cmd-enabled variant. We want the main one.
SRC_BIN="$(find "$TMP_DIR/bin" -type f -name 'kanata_linux_x64' | head -n 1)"
if [ -z "$SRC_BIN" ]; then
  echo "kanata_linux_x64 not found in the downloaded zip" >&2
  exit 1
fi

# Root-owned, because the service runs as root (a user-writable binary would be a privilege escalation).
# 'install' copies instead of moving, so the file gets the SELinux label of /usr/local/bin
# (bin_t) rather than keeping user_home_t, which systemd is not allowed to execute on Fedora.
echo "Installing Kanata to $BIN_PATH..."
sudo install -o root -g root -m 755 "$SRC_BIN" "$BIN_PATH"
if command -v restorecon > /dev/null; then
  sudo restorecon -v "$BIN_PATH"
fi

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
