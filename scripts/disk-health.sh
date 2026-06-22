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

    # Get all SMART attributes once
    local smart_all
    smart_all=$(smartctl -A "$dev" 2>/dev/null) || true

    # Temperature — different format for NVMe vs SATA
    local temp
    if [[ "$tran" == "nvme" ]]; then
        # NVMe: "Temperature:                        38 Celsius"
        temp=$(echo "$smart_all" | grep -i "^Temperature:" | grep -oP '\d+') || true
    else
        # SATA: "194 Temperature_Celsius ... - 45 (Min/Max 22/52)"
        # RAW_VALUE is the last number before any parenthetical
        temp=$(echo "$smart_all" | grep -i "Temperature_Celsius" | awk '{print $10}') || true
    fi
    if [ -n "$temp" ] && [ "$temp" -gt 0 ] && [ "$temp" -lt 150 ] 2>/dev/null; then
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
    hours=$(echo "$smart_all" | grep -i "power.on.hour\|Power On Hours" | grep -oP '[\d,]+' | tail -1 | tr -d ',') || true
    if [ -n "$hours" ] && [ "$hours" -gt 0 ] 2>/dev/null; then
        local days=$((hours / 24))
        local years=$((hours / 8760))
        local months=$(( (hours % 8760) / 730 ))
        if [ "$years" -gt 0 ]; then
            echo -e "  Power on:     ${hours} hours (~${years}y ${months}m)"
        else
            echo -e "  Power on:     ${hours} hours (${days} days)"
        fi
    fi

    # Power cycles
    local cycles
    cycles=$(echo "$smart_all" | grep -i "Power_Cycle_Count\|Power Cycles" | grep -oP '[\d,]+' | tail -1 | tr -d ',') || true
    [ -n "$cycles" ] && [ "$cycles" -gt 0 ] 2>/dev/null && echo -e "  Power cycles: ${cycles}"

    # Unsafe shutdowns / unexpected power loss
    local unsafe
    unsafe=$(echo "$smart_all" | grep -iE "Unsafe.Shutdown|Unexpected.*Power|Power.Lost|Power.Off.Retract|POR.Recovery" | grep -oP '[\d,]+' | tail -1 | tr -d ',') || true
    if [ -n "$unsafe" ] && [ "$unsafe" -gt 0 ] 2>/dev/null; then
        if [ "$unsafe" -ge 50 ]; then
            echo -e "  Unsafe stops: ${RED}${unsafe} (check power/sleep issues)${NC}"
        elif [ "$unsafe" -ge 10 ]; then
            echo -e "  Unsafe stops: ${YELLOW}${unsafe}${NC}"
        else
            echo -e "  Unsafe stops: ${unsafe}"
        fi
    fi

    # NVMe specific
    if [[ "$tran" == "nvme" ]]; then
        local pct_used
        pct_used=$(echo "$smart_all" | grep -i "Percentage Used" | awk '{print $NF}' | tr -d '%') || true
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
        data_written=$(echo "$smart_all" | grep -i "Data Units Written" | sed 's/.*\[//' | tr -d ']') || true
        [ -n "$data_written" ] && echo -e "  Written:      $data_written"

        local data_read
        data_read=$(echo "$smart_all" | grep -i "Data Units Read" | sed 's/.*\[//' | tr -d ']') || true
        [ -n "$data_read" ] && echo -e "  Read:         $data_read"

        local media_errors
        media_errors=$(echo "$smart_all" | grep -i "Media and Data Integrity" | grep -oP '\d+') || true
        if [ -n "$media_errors" ] && [ "$media_errors" -gt 0 ] 2>/dev/null; then
            echo -e "  Media errors: ${RED}${media_errors}${NC}"
        fi
    fi

    # SATA SSD / HDD specific
    if [[ "$tran" == "sata" || "$tran" == "ata" ]]; then
        # Reallocated sectors (bad sign if > 0)
        local realloc
        realloc=$(echo "$smart_all" | grep -i "Reallocated_Sector" | awk '{print $NF}') || true
        if [ -n "$realloc" ] && [ "$realloc" != "0" ]; then
            echo -e "  Reallocated:  ${RED}${realloc} sectors (WARNING)${NC}"
        elif [ -n "$realloc" ]; then
            echo -e "  Reallocated:  ${GREEN}0 sectors${NC}"
        fi

        # Wear leveling / SSD life (only SSDs have this)
        local wear
        wear=$(echo "$smart_all" | grep -iE "Wear_Leveling|SSD_Life_Left|Media_Wearout" | awk '{print $4}') || true
        if [ -n "$wear" ] && [ "$wear" -gt 0 ] 2>/dev/null; then
            local used=$((100 - wear))
            if [ "$wear" -le 20 ]; then
                echo -e "  SSD life:     ${RED}${wear}% remaining (${used}% used)${NC}"
            elif [ "$wear" -le 50 ]; then
                echo -e "  SSD life:     ${YELLOW}${wear}% remaining (${used}% used)${NC}"
            else
                echo -e "  SSD life:     ${GREEN}${wear}% remaining${NC}"
            fi
        fi

        # Data written / read (Total_LBAs_Written/Read — each LBA is 512 bytes)
        local lbas_written
        lbas_written=$(echo "$smart_all" | grep -iE "Total_LBAs_Written|Host_Writes" | awk '{print $NF}') || true
        if [ -n "$lbas_written" ] && [ "$lbas_written" -gt 0 ] 2>/dev/null; then
            local tb_written=$(awk "BEGIN {printf \"%.1f\", $lbas_written * 512 / 1000000000000}")
            echo -e "  Written:      ${tb_written} TB"
        fi

        local lbas_read
        lbas_read=$(echo "$smart_all" | grep -iE "Total_LBAs_Read|Host_Reads" | awk '{print $NF}') || true
        if [ -n "$lbas_read" ] && [ "$lbas_read" -gt 0 ] 2>/dev/null; then
            local tb_read=$(awk "BEGIN {printf \"%.1f\", $lbas_read * 512 / 1000000000000}")
            echo -e "  Read:         ${tb_read} TB"
        fi

        # Pending sectors
        local pending
        pending=$(echo "$smart_all" | grep -i "Current_Pending_Sector" | awk '{print $NF}') || true
        if [ -n "$pending" ] && [ "$pending" != "0" ]; then
            echo -e "  Pending:      ${RED}${pending} sectors (WARNING)${NC}"
        fi

        # Uncorrectable errors
        local uncorr
        uncorr=$(echo "$smart_all" | grep -i "Offline_Uncorrectable" | awk '{print $NF}') || true
        if [ -n "$uncorr" ] && [ "$uncorr" != "0" ]; then
            echo -e "  Uncorrectable:${RED} ${uncorr} errors (WARNING)${NC}"
        fi

        # HDD-specific: spin retry (sign of motor issues)
        local spin_retry
        spin_retry=$(echo "$smart_all" | grep -i "Spin_Retry_Count" | awk '{print $NF}') || true
        if [ -n "$spin_retry" ] && [ "$spin_retry" != "0" ]; then
            echo -e "  Spin retries: ${RED}${spin_retry} (motor issue)${NC}"
        fi

        # HDD-specific: seek errors
        local seek_err
        seek_err=$(echo "$smart_all" | grep -i "Seek_Error_Rate" | awk '{print $NF}') || true
        if [ -n "$seek_err" ] && [ "$seek_err" != "0" ] 2>/dev/null; then
            # Some drives report this as a composite value, only warn if VALUE ($4) is low
            local seek_val
            seek_val=$(echo "$smart_all" | grep -i "Seek_Error_Rate" | awk '{print $4}') || true
            if [ -n "$seek_val" ] && [ "$seek_val" -lt 60 ] 2>/dev/null; then
                echo -e "  Seek errors:  ${RED}degraded (value: ${seek_val})${NC}"
            fi
        fi

        # HDD-specific: start/stop count
        local start_stop
        start_stop=$(echo "$smart_all" | grep -i "Start_Stop_Count" | awk '{print $NF}') || true
        [ -n "$start_stop" ] && [ "$start_stop" -gt 0 ] 2>/dev/null && echo -e "  Start/stops:  ${start_stop}"
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
