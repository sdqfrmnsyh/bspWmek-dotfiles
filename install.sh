#!/usr/bin/env bash

set -e

echo "====================================="
echo " bspWmek Dotfiles Installer"
echo "====================================="

# --------------------------------------------------
# Detect Distribution
# --------------------------------------------------

if [ -f /etc/os-release ]; then
    . /etc/os-release
else
    echo "ERROR: Cannot detect Linux distribution."
    exit 1
fi

echo "Detected OS: $PRETTY_NAME"

case "$ID" in

    arch|endeavouros|manjaro|cachyos|garuda)
        DISTRO="arch"
        ;;

    debian|ubuntu|linuxmint|pop|neon|elementary)
        DISTRO="debian"
        ;;

    *)
        echo
        echo "ERROR: Unsupported distribution: $ID"
        echo
        echo "Supported:"
        echo "  Arch-based"
        echo "  Debian/Ubuntu-based"
        exit 1
        ;;

esac

echo "Package system: $DISTRO"

# --------------------------------------------------
# Package installation functions
# --------------------------------------------------

install_arch() {

    echo
    echo "[1/7] Preparing Arch package manager..."

    # ----------------------------------------------
    # Install yay
    # ----------------------------------------------

    if ! command -v yay >/dev/null 2>&1; then

        echo "Installing yay..."

        sudo pacman -S --needed --noconfirm git base-devel

        rm -rf /tmp/yay

        git clone https://aur.archlinux.org/yay.git /tmp/yay

        cd /tmp/yay
        makepkg -si --noconfirm
        cd -

        rm -rf /tmp/yay

    else
        echo "yay is already installed."
    fi

    # ----------------------------------------------
    # Packages
    # ----------------------------------------------

    echo
    echo "[3/7] Installing Arch dependencies..."

    yay -Syu --needed --noconfirm \
        bspwm \
        polybar \
        sxhkd \
        gvfs \
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
        git \
        nano \
        wget \
        curl \
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
        inter-font \
        ttf-ibm-plex \
        cantarell-fonts \
        noto-fonts \
        ttf-liberation \
        ttf-dejavu \
        ttf-nerd-fonts-symbols-mono
}


install_debian() {

    echo
    echo "[1/7] Updating Debian repositories..."

    sudo apt update

    echo
    echo "[3/7] Installing Debian dependencies..."

    sudo apt install -y \
        bspwm \
        polybar \
        sxhkd \
        gvfs \
        x11-xserver-utils \
        qtbase5-dev \
        picom \
        rofi \
        dunst \
        kitty \
        pcmanfm \
        fastfetch \
        playerctl \
        brightnessctl \
        libpulse-mainloop-glib0 \
        pavucontrol \
        scrot \
        policykit-1-gnome \
        xclip \
        ffmpeg \
        imagemagick \
        feh \
        git \
        nano \
        wget \
        curl \
        unzip \
        cava \
        htop \
        fonts-jetbrains-mono \
        fonts-noto \
        fonts-noto-cjk \
        fonts-noto-color-emoji \
        fonts-inter \
        fonts-ibm-plex \
        fonts-cantarell \
        fonts-liberation \
        fonts-dejavu \
        libnotify-bin \
        geany \
        alsa-utils

    # --------------------------------------------------
    # Optional packages
    # --------------------------------------------------

    echo
    echo "Checking optional Debian packages..."

    OPTIONAL_PACKAGES=(
        "mission-center"
    )

    for package in "${OPTIONAL_PACKAGES[@]}"; do

        if apt-cache show "$package" >/dev/null 2>&1; then
            sudo apt install -y "$package"
        else
            echo "Skipping unavailable package: $package"
        fi

    done
}

# --------------------------------------------------
# Install packages according to distro
# --------------------------------------------------

case "$DISTRO" in

    arch)
        install_arch
        ;;

    debian)
        install_debian
        ;;

esac

# --------------------------------------------------
# Copy Dotfiles
# --------------------------------------------------

echo
echo "[4/7] Installing dotfiles..."

cp -rf .config "$HOME/"
cp -rf .local "$HOME/"
cp -rf .scripts "$HOME/"
cp -rf Wallpapers "$HOME/"
cp -f .face "$HOME/"

# --------------------------------------------------
# Permissions
# --------------------------------------------------

echo
echo "[6/7] Setting permissions..."

chmod -R +x "$HOME/.scripts"
chmod -R +x "$HOME/.local/bin"

chmod +x "$HOME/.config/bspwm/bspwmrc"

# Fix typo from original script:
# sxkhd -> sxhkd

if [ -f "$HOME/.config/sxhkd/sxhkdrc" ]; then
    chmod +x "$HOME/.config/sxhkd/sxhkdrc"
fi

# --------------------------------------------------
# Reload bspwm
# --------------------------------------------------

echo
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

read -rp "Do you want to restart your system to apply all changes now? [y/N]: " reboot_choice

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