#!/bin/bash
############################
# desktop/xeon/fix.sh
# Apply commonly-recommended kernel-cmdline stability fixes for Xeon
# workstation boards to /boot/limine.conf. Standalone, manually run on
# the Xeon box — not wired into setup.sh/arch.sh.
#
# Usage:
#   ./desktop/xeon/fix.sh
############################

set -euo pipefail

LIMINE_CONF=/boot/limine.conf

# PCIe ASPM (Active State Power Management) causes random freezes on many
# Xeon workstation boards when the OS powers down idle PCIe links.
PARAM_PCIE_ASPM="pcie_aspm=off"

# Deep CPU C-states (C3/C6) are unreliable on several Xeon workstation
# chipsets and are a common cause of full-system hangs under load/idle
# transitions. Lower = more conservative (1 disables all but the
# shallowest states) — tune this if you find it's overly conservative.
CSTATE_LIMIT=1
PARAM_MAX_CSTATE="processor.max_cstate=${CSTATE_LIMIT}"
PARAM_INTEL_IDLE_CSTATE="intel_idle.max_cstate=${CSTATE_LIMIT}"

# The NMI watchdog can trigger spurious hard resets on Xeon/server boards
# whose firmware doesn't implement the watchdog timer correctly.
PARAM_NMI_WATCHDOG="nmi_watchdog=0"

DESIRED_PARAMS="$PARAM_PCIE_ASPM $PARAM_MAX_CSTATE $PARAM_INTEL_IDLE_CSTATE $PARAM_NMI_WATCHDOG"

echo "=== Xeon platform instability fixes ==="
echo ""
echo "Parameters to ensure: $DESIRED_PARAMS"
echo ""

# ——— Safety guard ———
# limine.conf's per-entry format can vary; only proceed if we can find the
# `cmdline:` key this script knows how to edit, rather than guessing.
if ! grep -q 'cmdline:' "$LIMINE_CONF"; then
    echo "✗ No 'cmdline:' line found in $LIMINE_CONF — aborting, format doesn't match what this"
    echo "  script expects. Add these params to your boot entry(ies) manually: $DESIRED_PARAMS"
    exit 1
fi

# ——— Apply to every boot entry's cmdline (main kernel, fallback, etc.) ———
tmpfile="$(mktemp)"
awk -v params="$DESIRED_PARAMS" '
    BEGIN { n = split(params, toks, " ") }
    /cmdline:/ {
        line = $0
        for (i = 1; i <= n; i++) {
            if (index(line, toks[i]) == 0) {
                line = line " " toks[i]
            }
        }
        print line
        next
    }
    { print }
' "$LIMINE_CONF" > "$tmpfile"

backup_file="$LIMINE_CONF.bak.$(date +%Y%m%d%H%M%S)"
sudo cp "$LIMINE_CONF" "$backup_file"
sudo cp "$tmpfile" "$LIMINE_CONF"
rm -f "$tmpfile"

echo "Backed up to $backup_file"
echo ""
echo "Diff:"
diff "$backup_file" "$LIMINE_CONF" || true

echo ""
echo "=== Done ==="
echo "⚠ Reboot required for these kernel parameters to take effect."
