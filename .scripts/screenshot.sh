#!/bin/bash

# Screenshot tool: full, area, window, countdown [detik]
# Usage: screenshot.sh {full|area|window|countdown [seconds]}

DIR="/home/modz/Pictures/Screenshots"
mkdir -p "$DIR"
TMP="/tmp/scrot_tmp.png"
rm -f "$TMP"

mode="${1:-full}"           # default fullscreen
delay="${2:-5}"             # default 5 detik untuk countdown
NOTIF_ID=9999

ambil_dan_simpan() {
    # Cek apakah file ada dan scrot sukses
    if [ ! -f "$TMP" ]; then
    killall dunst
        dunstify -u critical "❌ Screenshot Failed" "Image could not be created"
        exit 1
    fi

    # Ambil dimensi (lebar x tinggi)
    DIM=$(file "$TMP" | grep -oP '\d+ x \d+' | head -1 | tr -d ' ')
    if [ -z "$DIM" ]; then
    killall dunst
        dunstify -u critical "❌ Failed to read dimensions" "Ensure the 'file' is mounted"
        rm -f "$TMP"
        exit 1
    fi

    TIMESTAMP=$(date +"%Y-%m-%d-%H%M%S")
    NEWFILE="$DIR/${TIMESTAMP}_${DIM}.png"

    mv "$TMP" "$NEWFILE"
    if [ $? -ne 0 ]; then
    killall dunst
        dunstify -u critical "❌ Failed to move file" "Check folder permissions"
        exit 1
    fi

    # Clipboard
    xclip -selection clipboard -t image/png -i "$NEWFILE"
    if [ $? -eq 0 ]; then
        case "$mode" in
            full) desc="Fullscreen";;
            area) desc="Area Select";;
            window) desc="Jendela Aktif";;
            countdown) desc="Countdown";;
            *) desc="Screenshot";;
        esac
        killall dunst
        dunstify -i "$NEWFILE" "✅ $desc" "Copied to clipboard\n$(basename "$NEWFILE")" -t 4000
    else
    killall dunst
        dunstify -u critical "❌ Screenshot Failed" "Failed to copy to clipboard"
        exit 1
    fi
}

case "$mode" in
    full)
        scrot -q 100 -Z 0 "$TMP"
        killall dunst
        [ $? -ne 0 ] && { dunstify -u critical "❌ Fullscreen Failed" "scrot error"; exit 1; }
        ambil_dan_simpan
        ;;
    area)
        scrot -q 100 -Z 0 -s "$TMP"
        if [ $? -ne 0 ] || [ ! -f "$TMP" ]; then
        killall dunst
            dunstify "Area Cancelled" "No area selected" -t 2000
            exit 0
        fi
        ambil_dan_simpan
        ;;
    window)
        scrot -q 100 -Z 0 -u "$TMP"
        killall dunst
        [ $? -ne 0 ] && { dunstify -u critical "❌ Window Failed" "Unable to capture window"; exit 1; }
        ambil_dan_simpan
        ;;
    countdown)
        for (( i=delay; i>0; i-- )); do
        killall dunst
            dunstify -r "$NOTIF_ID" -t 900 "📸 Screenshot in ${i}..." "Do not move the window."
            sleep 1
        done
        killall dunst
        dunstify -r "$NOTIF_ID" -t 900 "📸 Now!" "Take a picture..."
        sleep 0.2
        scrot -q 100 -Z 0 "$TMP"
        killall dunst
        [ $? -ne 0 ] && { dunstify -u critical "❌ Countdown Failed" "script error"; exit 1; }
        ambil_dan_simpan
        ;;
    *)
        echo "Usage: $0 {full|area|window|countdown [second]}"
        exit 1
        ;;
esac
