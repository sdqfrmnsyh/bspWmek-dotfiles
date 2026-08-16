#!/bin/bash

case "$1" in
    main)
        rofi -show drun
        ;;
    rice)
        rofi -show drun /home/modz/.config/rofi/themes/nord.rasi
        ;;
    emoji)
        rofi -show emoji -theme ~/.config/rofi/themes/emoji.rasi
        ;;
    power)
        rofi -show power-menu -modi power-menu:rofi-power-menu -theme ~/.config/rofi/themes/power.rasi
        ;;
    *)
        echo "Usage: $0 {main|rice|emoji|power}"
        exit 1
        ;;
esac
