#!/bin/bash

# 1. Define the keywords for the 3 sinks you actually use
# Pattern 1: Your Bluetooth Speaker
# Pattern 2: Your main Analog/Headphone sink (usually the one without the numbers 3, 4, 5)
# Pattern 3: Your Speaker sink (you'll need to test which of the 'sof' sinks is the right one)
WHITELIST=("bluez_sink.FC_A8_9A_DE_AF_62.a2dp_sink" "alsa_output.pci-0000_00_1f.3-platform-skl_hda_dsp_generic.HiFi__hw_sofhdadsp__sink")

# 2. Get all sinks, but ONLY keep ones that match our whitelist
ALL_SINKS=($(pactl list short sinks | awk '{print $2}'))
MY_SINKS=()

for sink in "${ALL_SINKS[@]}"; do
    for pattern in "${WHITELIST[@]}"; do
        if [[ "$sink" == *"$pattern"* ]]; then
            MY_SINKS+=("$sink")
            break
        fi
    done
done

# 3. Get current default sink
CURRENT_SINK=$(pactl get-default-sink)

# 4. Find next sink in our filtered list
NEXT_SINK=""
for i in "${!MY_SINKS[@]}"; do
   if [[ "${MY_SINKS[$i]}" == "${CURRENT_SINK}" ]]; then
       NEXT_INDEX=$(( (i + 1) % ${#MY_SINKS[@]} ))
       NEXT_SINK=${MY_SINKS[$NEXT_INDEX]}
       break
   fi
done

# 5. Fallback if current sink wasn't in the whitelist
if [ -z "$NEXT_SINK" ]; then
    NEXT_SINK=${MY_SINKS[0]}
fi

# 6. Apply the change
pactl set-default-sink "$NEXT_SINK"

# 7. Move active streams
pactl list sink-inputs short | awk '{print $1}' | while read -r input; do
    pactl move-sink-input "$input" "$NEXT_SINK"
done

# 8. Clean Notification
notify-send "Audio Output" "Switched to: ${NEXT_SINK#*.}" -t 1500
