#!/bin/bash

# Find the primary battery interface (usually BAT0 or BAT1)
BAT_PATH=$(ls -d /sys/class/power_supply/BAT* 2>/dev/null | head -n 1)

if [ -z "$BAT_PATH" ]; then
    echo "Error: No battery interface found in /sys/class/power_supply/"
    echo "If this is a desktop PC, no battery will be detected."
    exit 1
fi

BAT_NAME=$(basename "$BAT_PATH")

# Helper function to read sysfs attributes safely
get_attr() {
    if [ -f "$BAT_PATH/$1" ]; then
        cat "$BAT_PATH/$1"
    else
        echo "0"
    fi
}

# Fetch raw metrics
STATUS=$(get_attr "status")
CAPACITY=$(get_attr "capacity")
CYCLE_COUNT=$(get_attr "cycle_count")

# Charge/Energy capacity values (can be reported in microamps 'charge' or microwatts 'energy')
ENERGY_FULL=$(get_attr "energy_full")
ENERGY_DESIGN=$(get_attr "energy_full_design")

if [ "$ENERGY_FULL" -eq 0 ]; then
    ENERGY_FULL=$(get_attr "charge_full")
    ENERGY_DESIGN=$(get_attr "charge_full_design")
fi

# Calculate health percentage using BC or AWK
if [ "$ENERGY_DESIGN" -gt 0 ]; then
    HEALTH=$(awk -v full="$ENERGY_FULL" -v design="$ENERGY_DESIGN" 'BEGIN { printf "%.2f", (full / design) * 100 }')
else
    HEALTH="N/A"
fi

# Format values for display (convert from micro-units to Wh or mAh standard equivalent)
FULL_FORMATTED=$(awk -v val="$ENERGY_FULL" 'BEGIN { printf "%.2f", val / 1000000 }')
DESIGN_FORMATTED=$(awk -v val="$ENERGY_DESIGN" 'BEGIN { printf "%.2f", val / 1000000 }')

echo "========================================"
echo "         BATTERY HEALTH REPORT          "
echo "========================================"
echo "Device Interface   : $BAT_NAME"
echo "Status             : $STATUS ($CAPACITY%)"
echo "Cycle Count        : $CYCLE_COUNT"
echo "Full Charge Cap    : $FULL_FORMATTED Wh / Ah"
echo "Design Capacity    : $DESIGN_FORMATTED Wh / Ah"
echo "----------------------------------------"
echo "Battery Health     : $HEALTH%"
echo "========================================"
