#!/bin/bash
############################
# scripts/fix-nvme-sleep.sh
# Fix NVMe sleep/wake issues by disabling deep power state transitions.
#
# Problem: Some NVMe drives (e.g. SSSTC) cause system hangs or data
# corruption on sleep/resume due to aggressive power saving (APST).
# The drive fails to wake from deep power states, causing unsafe shutdowns.
#
# Fix: Set nvme_core.default_ps_max_latency_us=0 in GRUB boot params,
# which disables NVMe Autonomous Power State Transitions (APST).
#
# Usage:
#   sudo ./scripts/fix-nvme-sleep.sh
############################

set -euo pipefail

GRUB_FILE="/etc/default/grub"
PARAM="nvme_core.default_ps_max_latency_us=0"

if [ "$EUID" -ne 0 ]; then
    echo "This script needs root access to modify GRUB."
    echo "Usage: sudo $0"
    exit 1
fi

# Check if already applied
if grep -q "$PARAM" "$GRUB_FILE" 2>/dev/null; then
    echo "✓ Fix already applied in $GRUB_FILE"
    echo "  Current: $(grep GRUB_CMDLINE_LINUX_DEFAULT "$GRUB_FILE")"
    exit 0
fi

# Backup grub config
cp "$GRUB_FILE" "${GRUB_FILE}.bak.$(date +%s)"
echo "→ Backed up $GRUB_FILE"

# Add the parameter to GRUB_CMDLINE_LINUX_DEFAULT
if grep -q '^GRUB_CMDLINE_LINUX_DEFAULT=' "$GRUB_FILE"; then
    # Append to existing value
    sed -i "s|^GRUB_CMDLINE_LINUX_DEFAULT=\"\(.*\)\"|GRUB_CMDLINE_LINUX_DEFAULT=\"\1 $PARAM\"|" "$GRUB_FILE"
    # Clean up double spaces if the original was empty
    sed -i 's|"  |"|' "$GRUB_FILE"
else
    echo "GRUB_CMDLINE_LINUX_DEFAULT=\"$PARAM\"" >> "$GRUB_FILE"
fi

echo "→ Added $PARAM to GRUB_CMDLINE_LINUX_DEFAULT"
echo "  Now: $(grep GRUB_CMDLINE_LINUX_DEFAULT "$GRUB_FILE")"

# Update GRUB
echo ""
echo "→ Updating GRUB..."
if command -v update-grub &>/dev/null; then
    update-grub
elif command -v grub2-mkconfig &>/dev/null; then
    grub2-mkconfig -o /boot/grub2/grub.cfg
else
    echo "⚠  Could not find update-grub or grub2-mkconfig"
    echo "   Run it manually after this script"
    exit 1
fi

echo ""
echo "=== NVMe sleep fix applied ==="
echo "Reboot for the change to take effect."
