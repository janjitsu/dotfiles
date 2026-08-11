#!/bin/bash
############################
# setup/fedora/nvidia.sh
# Install proprietary Nvidia drivers on Fedora Workstation via RPM Fusion's
# akmod-nvidia-580xx branch (Maxwell/Pascal — GTX 800/900/10 series,
# Fedora 44+), handling Secure Boot MOK enrollment when needed. Standalone,
# manually run on the
# Nvidia box — not wired into setup.sh/fedora.sh, since it needs a reboot
# + interactive MOK enrollment mid-process and would be wrong to run on a
# machine without an Nvidia GPU.
#
# Source: https://github.com/fady-saied/Nvidia-Fedora-Guide
#
# Usage:
#   ./setup/fedora/nvidia.sh
############################

set -euo pipefail

echo "=== Fedora Nvidia driver setup ==="
echo ""

# ——— Safety check ———
if ! lspci | grep -qi nvidia; then
    echo "✗ No Nvidia GPU detected via lspci — refusing to run on the wrong machine."
    exit 1
fi

# ——— RPM Fusion ———
echo "[1/4] Enabling RPM Fusion free + nonfree..."
sudo dnf install -y \
    "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
    "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm" \
    2>/dev/null || true

# ——— Secure Boot MOK enrollment ———
SECURE_BOOT=false
if mokutil --sb-state 2>/dev/null | grep -qi "SecureBoot enabled"; then
    SECURE_BOOT=true
fi

if [ "$SECURE_BOOT" = true ]; then
    echo "[2/4] Secure Boot is enabled — setting up MOK signing key..."
    sudo dnf install -y kmodtool akmods mokutil openssl

    MOK_CERT=/etc/pki/akmods/certs/public_key.der
    if [ -f "$MOK_CERT" ]; then
        echo "  → MOK cert already exists at $MOK_CERT, skipping generation"
    else
        sudo kmodgenca -a
    fi

    echo "  → Importing MOK cert (you'll be asked to set an enrollment password)"
    sudo mokutil --import "$MOK_CERT"
    echo "  ⚠ On next reboot, the MOK Management screen will appear:"
    echo "    select \"Enroll MOK\" → \"Continue\" → \"Yes\" → enter the password you just set"
else
    echo "[2/4] Secure Boot is disabled — skipping MOK enrollment"
fi

# ——— Install drivers ———
echo "[3/4] Installing akmod-nvidia-580xx + CUDA driver..."
sudo dnf install -y xorg-x11-drv-nvidia-580xx akmod-nvidia-580xx
sudo dnf install -y xorg-x11-drv-nvidia-580xx-cuda

echo "[4/4] Waiting for the akmod kernel module to finish building..."
for _ in $(seq 1 30); do
    if modinfo -F version nvidia &>/dev/null; then
        break
    fi
    sleep 20
done

if modinfo -F version nvidia &>/dev/null; then
    echo "  → nvidia kernel module built: $(modinfo -F version nvidia)"
else
    echo "  ⚠ Module isn't built yet — check status with: modinfo -F version nvidia"
fi

echo ""
echo "=== Done ==="
if [ "$SECURE_BOOT" = true ]; then
    echo "⚠ Reboot required — enroll the MOK key at the blue screen, then log back in."
else
    echo "⚠ Reboot required for the driver to take effect."
fi
echo "  After reboot, verify with: nvidia-smi"
