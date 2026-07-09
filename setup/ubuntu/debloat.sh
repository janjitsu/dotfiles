#!/bin/bash
############################
# Remove Snap and Flatpak from Ubuntu
############################

echo "=== Removing Snap ==="
if command -v snap >/dev/null 2>&1; then
    snap list 2>/dev/null | awk 'NR>1{print $1}' | while read pkg; do
        sudo snap remove --purge "$pkg" 2>/dev/null || true
    done
    sudo systemctl stop snapd 2>/dev/null || true
    sudo systemctl disable snapd 2>/dev/null || true
    sudo apt remove --purge --assume-yes snapd gnome-software-plugin-snap
    sudo rm -rf ~/snap /snap /var/snap /var/lib/snapd
    # Prevent snap from being reinstalled
    sudo tee /etc/apt/preferences.d/no-snap.pref > /dev/null <<EOF
Package: snapd
Pin: release a=*
Pin-Priority: -10
EOF
    echo "→ Snap removed"
else
    echo "→ Snap not installed, skipping"
fi

echo ""
echo "=== Removing Flatpak ==="
if command -v flatpak >/dev/null 2>&1; then
    flatpak list 2>/dev/null | awk '{print $2}' | while read pkg; do
        sudo flatpak uninstall --noninteractive "$pkg" 2>/dev/null || true
    done
    sudo apt remove --purge --assume-yes flatpak gnome-software-plugin-flatpak 2>/dev/null || true
    sudo rm -rf /var/lib/flatpak ~/.local/share/flatpak
    echo "→ Flatpak removed"
else
    echo "→ Flatpak not installed, skipping"
fi

echo ""
echo "=== Debloat complete ==="
