#!/bin/bash
# Auto display switch + notifikasi dunstify

# Pastikan dunstify tersedia, fallback ke notify-send atau abaikan
if command -v dunstify &>/dev/null; then
    NOTIFY="dunstify"
elif command -v notify-send &>/dev/null; then
    NOTIFY="notify-send"
else
    NOTIFY=""
fi

HDMI=$(xrandr --query | grep -w connected | grep -i hdmi | awk '{print $1}')
EDP=$(xrandr --query | grep -w connected | grep -i edp | awk '{print $1}')

if [ -n "$HDMI" ]; then
    xrandr --output "$HDMI" --primary --mode 1280x720 --set "max bpc" 18 --set "Broadcast RGB" "Full"
    [ -n "$EDP" ] && xrandr --output "$EDP" --off
    [ -n "$NOTIFY" ] && $NOTIFY -i video-display "HDMI Connected" "Switched to external display only ($HDMI)" -t 3000
else
    [ -n "$EDP" ] && xrandr --output "$EDP" --primary --mode 1280x720
    [ -n "$NOTIFY" ] && $NOTIFY -i computer-laptop "No HDMI" "Using laptop screen ($EDP)" -t 3000
fi
