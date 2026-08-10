#!/bin/bash
############################
# desktop/nvidia/fix.sh
# Apply the standard Hyprland-Nvidia stability fixes (modprobe options,
# early-KMS initramfs modules, Hyprland env vars). Standalone, manually
# run on the Nvidia + Hyprland box — not wired into setup.sh/arch.sh.
#
# Usage:
#   ./desktop/nvidia/fix.sh
############################

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DESKTOP_DIR="$(cd "$DIR/.." && pwd)"

echo "=== Nvidia + Hyprland instability fixes ==="
echo ""

# ——— Safety check ———
if ! lspci | grep -qi nvidia; then
    echo "✗ No Nvidia GPU detected via lspci — refusing to run on the wrong machine."
    exit 1
fi

# ——— modprobe.d drop-in ———
echo "[1/3] Linking Nvidia modprobe.d drop-in..."
sudo ln -sf "$DIR/nvidia.conf" /etc/modprobe.d/nvidia.conf
echo "  → /etc/modprobe.d/nvidia.conf"

# ——— mkinitcpio early KMS ———
echo "[2/3] Ensuring early-KMS Nvidia modules in mkinitcpio.conf..."
MKINITCPIO_CONF=/etc/mkinitcpio.conf
NVIDIA_MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)

current_line="$(grep -E '^MODULES=\(' "$MKINITCPIO_CONF" || true)"
if [ -z "$current_line" ]; then
    echo "✗ Could not find a MODULES=(...) line in $MKINITCPIO_CONF — aborting."
    echo "  Add these modules to it manually: ${NVIDIA_MODULES[*]}"
    exit 1
fi
if [[ "$current_line" != *")"* ]]; then
    echo "✗ MODULES=(...) in $MKINITCPIO_CONF spans multiple lines already — aborting to avoid"
    echo "  corrupting a hand-edited array. Add these modules to it manually: ${NVIDIA_MODULES[*]}"
    exit 1
fi

existing="${current_line#MODULES=(}"
existing="${existing%)}"
read -ra existing_modules <<< "$existing"

missing=()
for m in "${NVIDIA_MODULES[@]}"; do
    if [[ ! " ${existing_modules[*]} " == *" $m "* ]]; then
        missing+=("$m")
    fi
done

if [ ${#missing[@]} -eq 0 ]; then
    echo "  → Nvidia modules already present, nothing to do"
else
    new_modules="$(echo "${missing[*]} ${existing_modules[*]}" | xargs)"
    tmpfile="$(mktemp)"

    awk -v mods="$new_modules" '
        /^MODULES=\(/ {
            print "# nvidia         — core proprietary driver, must bind the GPU before any display code touches it"
            print "# nvidia_modeset — KMS/mode-setting support, needed for early KMS to avoid a mode-switch flicker at boot"
            print "# nvidia_uvm     — unified memory, needed for CUDA/compute workloads that touch the GPU"
            print "# nvidia_drm     — DRM interface, what Hyprland (via wlroots) actually binds to"
            print "MODULES=(" mods ")"
            next
        }
        { print }
    ' "$MKINITCPIO_CONF" > "$tmpfile"

    sudo cp "$MKINITCPIO_CONF" "$MKINITCPIO_CONF.bak.$(date +%Y%m%d%H%M%S)"
    sudo cp "$tmpfile" "$MKINITCPIO_CONF"
    rm -f "$tmpfile"

    echo "  → Added: ${missing[*]}"
    echo "  → Rebuilding initramfs..."
    sudo mkinitcpio -P
fi

# ——— Hyprland env vars ———
echo "[3/3] Uncommenting Nvidia env vars in Hyprland config..."
sed -i 's/^-- hl\.env/hl.env/' "$DESKTOP_DIR/hyprland/hypr/config/environment.lua"
echo "  → desktop/hyprland/hypr/config/environment.lua"

echo ""
echo "=== Done ==="
echo "⚠ Reboot required for the modprobe/initramfs changes to take effect."
