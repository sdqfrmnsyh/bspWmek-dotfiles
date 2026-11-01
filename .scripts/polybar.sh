#!/usr/bin/env bash

# Hentikan instance polybar yang sedang berjalan
killall -q polybar

# Tunggu sampai proses benar-benar selesai
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Jalankan Polybar di setiap monitor yang terhubung
if type "xrandr" > /dev/null; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    MONITOR=$m polybar -r -c ~/.config/polybar/bconfig.ini &
  done
else
  polybar -r -c ~/.config/polybar/bconfig.ini &
fi
