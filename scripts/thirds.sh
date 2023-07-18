#!/bin/bash
# run script like so:  bash thirds.sh NUMBER
# where NUMBER is 0,1 or 2
# 0 is left, 1 is center, 2 is right
get_screen_geometry()
{
   # determine size of the desktop
   xwininfo -root | \
   awk  -F ':' '/Width/{printf "%d",$2/3}/Height/{print $2}'
}
xdotool getactivewindow windowsize $(get_screen_geometry )

xdotool getactivewindow windowmove \
$(get_screen_geometry | awk -v POS=$1  '{ printf "%d ", POS*$1  }'  ) 0
