#!/bin/bash
############################
# scripts/disk-health.sh
# Check health of all drives using SMART data.
# Requires: smartmontools (smartctl)
#
# Usage:
#   sudo ./scripts/disk-health.sh
#   sudo ./scripts/disk-health.sh /dev/sda
############################

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

if [ "$EUID" -ne 0 ]; then
    echo "This script needs root access to read SMART data."
    echo "Usage: sudo $0 [/dev/device]"
    exit 1
fi

if ! command -v smartctl &>/dev/null; then
    echo "smartctl not found, installing smartmontools..."
    if command -v apt-get &>/dev/null; then
        apt-get update -qq && apt-get install -y -qq smartmontools
    elif command -v dnf &>/dev/null; then
        dnf install -y -q smartmontools
    else
        echo "✗ Could not install smartmontools — unsupported package manager"
        exit 1
    fi
fi

check_drive() {
    local dev="$1"
    local name=$(basename "$dev")
    local model=$(lsblk -dno MODEL "$dev" 2>/dev/null | xargs)
    local size=$(lsblk -dno SIZE "$dev" 2>/dev/null | xargs)
    local tran=$(lsblk -dno TRAN "$dev" 2>/dev/null | xargs)

    echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}${BOLD} $dev ${NC}— ${model:-unknown} (${size:-?}, ${tran:-?})"
    echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # Get SMART health status
    local health
    health=$(smartctl -H "$dev" 2>/dev/null | grep -i "result\|status" | head -1) || true

    if echo "$health" | grep -qi "PASSED\|OK"; then
        echo -e "  Health:       ${GREEN}✓ PASSED${NC}"
    elif [ -z "$health" ]; then
        echo -e "  Health:       ${YELLOW}? Unknown (SMART not supported?)${NC}"
    else
        echo -e "  Health:       ${RED}✗ FAILING — $health${NC}"
    fi

    # Temperature
    local temp
    temp=$(smartctl -A "$dev" 2>/dev/null | grep -i "temperature" | head -1 | awk '{for(i=1;i<=NF;i++) if($i+0==$i && $i>0 && $i<200) {print $i; exit}}') || true
    if [ -n "$temp" ]; then
        if [ "$temp" -ge 60 ]; then
            echo -e "  Temperature:  ${RED}${temp}°C (HOT!)${NC}"
        elif [ "$temp" -ge 45 ]; then
            echo -e "  Temperature:  ${YELLOW}${temp}°C${NC}"
        else
            echo -e "  Temperature:  ${GREEN}${temp}°C${NC}"
        fi
    fi

    # Power on hours
    local hours
    hours=$(smartctl -A "$dev" 2>/dev/null | grep -i "power.on.hour\|Power On Hours" | awk '{for(i=NF;i>=1;i--) if($i+0==$i) {print $i; exit}}') || true
    if [ -n "$hours" ]; then
        local days=$((hours / 24))
        local years=$(echo "scale=1; $hours / 8760" | bc 2>/dev/null || echo "?")
        echo -e "  Power on:     ${hours} hours (${days} days / ~${years} years)"
    fi

    # NVMe specific
    if [[ "$tran" == "nvme" ]]; then
        local nvme_info
        nvme_info=$(smartctl -A "$dev" 2>/dev/null) || true

        local pct_used
        pct_used=$(echo "$nvme_info" | grep -i "Percentage Used" | awk '{print $NF}' | tr -d '%') || true
        if [ -n "$pct_used" ]; then
            if [ "$pct_used" -ge 80 ]; then
                echo -e "  Life used:    ${RED}${pct_used}%${NC}"
            elif [ "$pct_used" -ge 50 ]; then
                echo -e "  Life used:    ${YELLOW}${pct_used}%${NC}"
            else
                echo -e "  Life used:    ${GREEN}${pct_used}%${NC}"
            fi
        fi

        local data_written
        data_written=$(echo "$nvme_info" | grep -i "Data Units Written" | sed 's/.*\[//' | tr -d ']') || true
        [ -n "$data_written" ] && echo -e "  Written:      $data_written"

        local data_read
        data_read=$(echo "$nvme_info" | grep -i "Data Units Read" | sed 's/.*\[//' | tr -d ']') || true
        [ -n "$data_read" ] && echo -e "  Read:         $data_read"
    fi

    # SATA SSD / HDD specific
    if [[ "$tran" == "sata" || "$tran" == "ata" ]]; then
        local smart_attrs
        smart_attrs=$(smartctl -A "$dev" 2>/dev/null) || true

        # Reallocated sectors (bad sign if > 0)
        local realloc
        realloc=$(echo "$smart_attrs" | grep -i "Reallocated_Sector" | awk '{print $NF}') || true
        if [ -n "$realloc" ] && [ "$realloc" != "0" ]; then
            echo -e "  Reallocated:  ${RED}${realloc} sectors (WARNING)${NC}"
        elif [ -n "$realloc" ]; then
            echo -e "  Reallocated:  ${GREEN}0 sectors${NC}"
        fi

        # Wear leveling / SSD life
        local wear
        wear=$(echo "$smart_attrs" | grep -iE "Wear_Leveling|SSD_Life_Left|Media_Wearout" | awk '{print $(NF-3)}') || true
        if [ -n "$wear" ]; then
            if [ "$wear" -le 20 ]; then
                echo -e "  SSD life:     ${RED}${wear}%${NC}"
            elif [ "$wear" -le 50 ]; then
                echo -e "  SSD life:     ${YELLOW}${wear}%${NC}"
            else
                echo -e "  SSD life:     ${GREEN}${wear}%${NC}"
            fi
        fi

        # Pending sectors
        local pending
        pending=$(echo "$smart_attrs" | grep -i "Current_Pending_Sector" | awk '{print $NF}') || true
        if [ -n "$pending" ] && [ "$pending" != "0" ]; then
            echo -e "  Pending:      ${RED}${pending} sectors (WARNING)${NC}"
        fi

        # Uncorrectable errors
        local uncorr
        uncorr=$(echo "$smart_attrs" | grep -i "Offline_Uncorrectable" | awk '{print $NF}') || true
        if [ -n "$uncorr" ] && [ "$uncorr" != "0" ]; then
            echo -e "  Uncorrectable:${RED} ${uncorr} errors (WARNING)${NC}"
        fi
    fi

    echo ""
}

# ——— Main ———
echo ""
echo -e "${BOLD}=== Disk Health Report ===${NC}"
echo -e "Date: $(date)"
echo ""

if [ $# -gt 0 ]; then
    # Check specific device
    check_drive "$1"
else
    # Check all physical drives
    lsblk -dno NAME,TYPE | while read name type; do
        [ "$type" != "disk" ] && continue
        check_drive "/dev/$name"
    done
fi
