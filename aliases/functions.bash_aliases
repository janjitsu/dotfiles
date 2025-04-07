#!/bin/bash

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
function alert {
    notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" \
    "$(history|tail -n1|sed -e 's/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//')"
    for i in {1..3}; do
        paplay /usr/share/sounds/gnome/default/alerts/glass.ogg; sleep 0.1
    done
}

alias prettyjson='python -m json.tool'
