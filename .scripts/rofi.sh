#!/bin/bash

case "$1" in
    main)
        rofi -no-lazy-grab -show drun -drun-match-fields
        ;;
    emoji)
        rofi -show emoji -plugin-path /usr/lib/rofi -no-lazy-grab -theme ~/.config/rofi/themes/emoji.rasi -emoji-format '{emoji}' -click-to-execute true -hover-select true
        ;;
    power)
        rofi -no-lazy-grab -show powermenu -modi powermenu:rofi-power-menu -theme ~/.config/rofi/themes/power.rasi
        ;;
    *)
        echo "Usage: $0 {main|emoji|power}"
        exit 1
        ;;
esac
