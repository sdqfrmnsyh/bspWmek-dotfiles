#!/usr/bin/env bash

set -e

echo "====================================="
echo "      bspWmek Dotfiles Installer"
echo "====================================="

# --------------------------------------------------
# Install Chaotic-AUR
# --------------------------------------------------

echo "[1/7] Setting up Chaotic-AUR..."

if ! grep -q "^chaotic-aur" /etc/pacman.conf; then
echo "Installing Chaotic-AUR keyring and mirrorlist..."

sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key 3056513887B78AEB

sudo pacman -U --noconfirm \
    'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' \
    'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

echo "Enabling Chaotic-AUR repository..."

sudo tee -a /etc/pacman.conf >/dev/null <<'EOF'

[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist
EOF

sudo pacman -Syu --noconfirm

else
echo "Chaotic-AUR is already enabled."
fi

# --------------------------------------------------
# Install yay
# --------------------------------------------------

if ! command -v yay &>/dev/null; then
    echo "[2/7] Installing yay..."

    sudo pacman -S --needed git base-devel

    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si --noconfirm
    cd -

    rm -rf /tmp/yay
fi

# --------------------------------------------------
# Install Packages
# --------------------------------------------------

echo "[3/7] Installing dependencies..."

yay -Syu --needed --noconfirm \
polybar \
snixembed \
xorg-xset \
qt5-base \
qt5-tools \
picom-ftlabs-git \
rofi \
rofi-emoji \
rofi-power-menu \
dunst \
kitty \
pcmanfm \
fastfetch \
playerctl \
brightnessctl \
pamixer \
networkmanager \
pavucontrol \
scrot \
polkit-gnome \
xclip \
ffmpeg \ 
imagemagick \
mission-center \
feh \
mv \
git \
brave-origin-bin \
nano \
wget \
curl \
cp \
unzip \
ananicy-cpp \
cachyos-ananicy-rules \
cava \
htop \
ttf-jetbrains-mono-nerd \
ttf-material-design-icons-desktop \
adobe-source-han-code-jp-fonts \
libnotify \
geany \
alsa-utils \
htop \
inter-font \
ttf-ibm-plex \
cantarell-fonts \
noto-fonts \
ttf-liberation \
ttf-dejavu \
ttf-nerd-fonts-symbols-mono

# --------------------------------------------------
# Copy Dotfiles
# --------------------------------------------------

echo "[4/7] Installing dotfiles..."

cp -rf .config "$HOME/"
cp -rf .local "$HOME/"
cp -rf .scripts "$HOME/"
cp -rf Wallpapers "$HOME/"

cp -f .face "$HOME/"

# --------------------------------------------------
# Permissions
# --------------------------------------------------

echo "[6/7] Setting permissions..."

chmod -R +x "$HOME/.scripts"
chmod -R +x "$HOME/.local/bin"
chmod +x "$HOME/.config/bspwm/bspwmrc"
chmod +x "$HOME/.config/sxkhd/sxkhdrc"

# --------------------------------------------------
# Reload bspwm
# --------------------------------------------------

echo "[7/7] Reloading bspwm..."

bspc wm -r 2>/dev/null || true
pkill -USR1 -x sxhkd 2>/dev/null || true

echo
echo "====================================="
echo " Installation Complete!"
echo "====================================="
echo
echo "Please log out and log back in."
echo

read -rp "Do you want to restart your system to apply all changes now? [y/N]: " reboot_choice0

case "$reboot_choice" in
    [Yy]|[Yy][Ee][Ss])
        echo "Rebooting..."
        sleep 2
        sudo reboot
        ;;
    *)
        echo "No restart selected."
        ;;
esac
