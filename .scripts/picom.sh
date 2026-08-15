#!/bin/bash
ID=9992
if pgrep -x xwinwrap >/dev/null; then
    feh --bg-fill /home/modz/.scripts/hy.png
fi

if pgrep -x picom >/dev/null; then
    killall picom
    dunstify -r $ID -u normal "Picom status" "Disabled"
else
    taskset -c 0 nice -n 19 ionice -c3 stdbuf -oL -eL chrt --idle 0 setsid picom -b >/dev/null 2>&1 &
    dunstify -r $ID -u normal "Picom status" "Enabled"
fi
