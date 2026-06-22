#!/bin/bash
############################
# Remove Snap and Flatpak from Fedora
############################

echo "=== Removing Snap ==="
if command -v snap >/dev/null 2>&1; then
    snap list 2>/dev/null | awk 'NR>1{print $1}' | while read pkg; do
        sudo snap remove --purge "$pkg" 2>/dev/null || true
    done
    sudo systemctl stop snapd
    sudo systemctl disable snapd
    sudo dnf remove -y snapd
    sudo rm -rf ~/snap /snap /var/snap /var/lib/snapd
    echo "→ Snap removed"
else
    echo "→ Snap not installed, skipping"
fi

echo ""
echo "=== Removing Flatpak ==="
if command -v flatpak >/dev/null 2>&1; then
    flatpak list --app --columns=application 2>/dev/null | while read pkg; do
        sudo flatpak uninstall --noninteractive "$pkg" 2>/dev/null || true
    done
    sudo dnf remove -y flatpak
    sudo rm -rf /var/lib/flatpak ~/.local/share/flatpak
    echo "→ Flatpak removed"
else
    echo "→ Flatpak not installed, skipping"
fi

echo ""
echo "=== Debloat complete ==="
