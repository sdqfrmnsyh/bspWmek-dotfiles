#!/usr/bin/env bash
# /etc/sddm/scripts/Xsetup — auto-detect, eDP kiri / HDMI kanan, HDMI primary

set -u
MODE="1280x720"
RATE="60"
BPC="16"

# 1. Tunggu X/xrandr siap
i=0
until xrandr --query >/dev/null 2>&1; do
    i=$((i+1)); [ "$i" -ge 20 ] && exit 1; sleep 0.1
done

# 2. Deteksi output connected
mapfile -t RAW < <(xrandr --query | awk '/ connected/ {print $1}')
[ "${#RAW[@]}" -eq 0 ] && exit 1

# 3. Urutkan: non-HDMI (eDP/DP/LVDS) ke KIRI, HDMI ke KANAN
OUTS=()
for o in "${RAW[@]}"; do
    case "$o" in eDP-*|DP-*|LVDS-*) OUTS+=("$o") ;; esac
done
for o in "${RAW[@]}"; do
    case "$o" in HDMI-*) OUTS+=("$o") ;; esac
done
# Sisa output lain (kalau ada) taruh di akhir
for o in "${RAW[@]}"; do
    case "$o" in eDP-*|DP-*|LVDS-*|HDMI-*) ;; *) OUTS+=("$o") ;; esac
done

# 4. Primary: HDMI (kalau ada), else output pertama
PRIMARY=""
for o in "${OUTS[@]}"; do
    case "$o" in HDMI-*) PRIMARY="$o"; break ;; esac
done
[ -z "$PRIMARY" ] && PRIMARY="${OUTS[0]}"

# 5. Helper: pilih mode terbaik
best_mode() {
    local o="$1" m
    m=$(xrandr --query | awk -v o="$o" -v w="$MODE" '
        $1==o{f=1;next} f&&/^[^ ]/{exit} f&&$1==w{print w" "$2;exit}')
    [ -z "$m" ] && m=$(xrandr --query | awk -v o="$o" '
        $1==o{f=1;next} f&&/^[^ ]/{exit} f&&/x/{print $1" "$2;exit}')
    echo "$m"
}

# 6. Helper: cek property ada di output
has_prop() {
    xrandr --prop | awk -v o="$1" '
        $0~"^"o" connected"{f=1;next} f&&/^[^ \t]/{exit}
        f&&/^[ \t]+[A-Za-z]/{gsub(/^[ \t]+/,"");sub(/:.*/,"");print}' \
        | grep -qxF "$2"
}

# 7. Layout — LEFT-to-RIGHT, kiri = OUTS[0], kanan = OUTS[1], dst.
LAYOUT=(xrandr)
X=0
for o in "${OUTS[@]}"; do
    mr=$(best_mode "$o"); m="${mr% *}"; w="${m%x*}"
    LAYOUT+=(--output "$o")
    [ "$o" = "$PRIMARY" ] && LAYOUT+=(--primary)
    LAYOUT+=(--mode "$m" --rate "${mr#* }" --pos "${X}x0" --rotate normal)
    X=$((X + w))
done
"${LAYOUT[@]}"

# 8. Properti per-output (hanya yang ada)
for o in "${OUTS[@]}"; do
    has_prop "$o" "color format"                  && xrandr --output "$o" --set "color format" "RGB"
    has_prop "$o" "Broadcast RGB"                 && xrandr --output "$o" --set "Broadcast RGB" "Full"
    has_prop "$o" "max bpc"                       && xrandr --output "$o" --set "max bpc" "$BPC"
    has_prop "$o" "TearFree"                      && xrandr --output "$o" --set "TearFree" on
    has_prop "$o" "Colorspace"                    && xrandr --output "$o" --set "Colorspace" "opRGB"
    has_prop "$o" "content type"                  && xrandr --output "$o" --set "content type" "Game"
    has_prop "$o" "scaling mode"                  && xrandr --output "$o" --set "scaling mode" "None"
    has_prop "$o" "adaptive backlight modulation" && xrandr --output "$o" --set "adaptive backlight modulation" "off"
    has_prop "$o" "vrr_capable"                   && xrandr --output "$o" --set "vrr_capable" 1          || true
    has_prop "$o" "passive_vrr_capable"           && xrandr --output "$o" --set "passive_vrr_capable" 1  || true
done
