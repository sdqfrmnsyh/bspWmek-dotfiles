#!/usr/bin/env bash

set -e

echo "====================================="
echo "      bspWmek Dotfiles Installer"
echo "====================================="
echo

# ==================================================
# Detect Package Manager
# ==================================================

echo "[1/7] Detecting package manager..."

APT_WORKS=false
PACMAN_WORKS=false

# Test APT
if command -v apt >/dev/null 2>&1; then
    if sudo apt update >/dev/null 2>&1; then
        APT_WORKS=true
    fi
fi

# Test Pacman
if command -v pacman >/dev/null 2>&1; then
    if sudo pacman -Syu --noconfirm >/dev/null 2>&1; then
        PACMAN_WORKS=true
    fi
fi

# --------------------------------------------------
# Determine distro from package manager
# --------------------------------------------------

if [ "$APT_WORKS" = true ] && [ "$PACMAN_WORKS" = false ]; then

    DISTRO="debian"

elif [ "$APT_WORKS" = false ] && [ "$PACMAN_WORKS" = true ]; then

    DISTRO="arch"

elif [ "$APT_WORKS" = true ] && [ "$PACMAN_WORKS" = true ]; then

    echo
    echo "ERROR: Both APT and Pacman are working."
    echo "Cannot safely determine the package manager."
    exit 1

else

    echo
    echo "ERROR: Neither APT nor Pacman is working."
    echo "Unsupported distribution."
    exit 1

fi

echo "Detected package manager: $DISTRO"
echo

# ==================================================
# ARCH
# ==================================================

install_arch() {

    echo "====================================="
    echo " Arch Linux installation"
    echo "====================================="
    echo

    # --------------------------------------------------
    # Chaotic-AUR
    # --------------------------------------------------

    echo "[2/7] Installing Chaotic-AUR..."

    if ! pacman -Q chaotic-keyring >/dev/null 2>&1; then

        sudo pacman-key --recv-key \
            3056513887B78AEB \
            --keyserver keyserver.ubuntu.com

        sudo pacman-key --lsign-key 3056513887B78AEB

        sudo pacman -U --noconfirm \
            'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst' \
            'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

        if ! grep -q "^\[chaotic-aur\]" /etc/pacman.conf; then

            sudo tee -a /etc/pacman.conf >/dev/null <<'EOF'

[chaotic-aur]
Include = /etc/pacman.d/chaotic-mirrorlist
EOF

        fi

    else
        echo "Chaotic-AUR already installed."
    fi

    sudo pacman -Syu --noconfirm

    # --------------------------------------------------
    # yay
    # --------------------------------------------------

    echo
    echo "[3/7] Installing yay..."

    if ! command -v yay >/dev/null 2>&1; then

        sudo pacman -S --needed --noconfirm \
            git \
            base-devel

        rm -rf /tmp/yay

        git clone https://aur.archlinux.org/yay.git /tmp/yay

        cd /tmp/yay
        makepkg -si --noconfirm
        cd -

        rm -rf /tmp/yay

    else
        echo "yay already installed."
    fi

    # --------------------------------------------------
    # Arch packages
    # --------------------------------------------------

    echo
    echo "Installing Arch packages..."

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
        fish \
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

# ==================================================
# DEBIAN / UBUNTU
# ==================================================

install_debian() {

    echo "====================================="
    echo " Debian / Ubuntu installation"
    echo "====================================="
    echo

    echo "[2/7] Updating APT repositories..."

    sudo apt update

    echo
    echo "[3/7] Installing Debian packages..."

    sudo apt install -y \
        bspwm \
        fish \
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
        pavucontrol \
        scrot \
        mate-polkit \
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
        fonts-cantarell \
        fonts-liberation \
        fonts-dejavu \
        libnotify-bin \
        geany \
        alsa-utils


mkdir -p ~/.local/share/fonts
wget https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip JetBrainsMono.zip -d ~/.local/share/fonts/
rm JetBrainsMono.zip

    echo
    echo "Debian packages installed."

    # --------------------------------------------------
    # Optional packages
    # --------------------------------------------------

    echo
    echo "Checking optional packages..."

    OPTIONAL_PACKAGES=(
        mission-center
    )

    for package in "${OPTIONAL_PACKAGES[@]}"; do

        if apt-cache show "$package" >/dev/null 2>&1; then
            sudo apt install -y "$package"
        else
            echo "Skipping unavailable package: $package"
        fi

    done
}

# ==================================================
# Install packages
# ==================================================

if [ "$DISTRO" = "arch" ]; then

    install_arch

elif [ "$DISTRO" = "debian" ]; then

    install_debian

fi

# ==================================================
# Copy ALL Dotfiles
# ==================================================

echo
echo "[4/7] Copying ALL dotfiles..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Copy everything recursively, including hidden files.
# cp -a preserves permissions, timestamps, symlinks, etc.

cp -a "$SCRIPT_DIR/." "$HOME/"

echo "All files copied."

# ==================================================
# chmod +x EVERYTHING
# ==================================================

echo
echo "[5/7] Making ALL files executable..."

# chmod every file recursively from the root of the
# installed dotfiles.

find "$HOME/.config" \
     "$HOME/.local" \
     "$HOME/.scripts" \
     -type f \
     -exec chmod +x {} +

# Also make every directory accessible.
find "$HOME/.config" \
     "$HOME/.local" \
     "$HOME/.scripts" \
     "$HOME/Wallpapers" \
     -type d \
     -exec chmod +x {} +

# set fish as default
chsh -s /usr/bin/fish

# set local bin as usr bin
echo 'export PATH="$HOME/.local/bin:$PATH"' | sudo tee /etc/profile.d/local-bin.sh
echo 'fish_add_path $HOME/.local/bin' | sudo tee /etc/fish/conf.d/local-bin.fish


# ==================================================
# bspwm / sxhkd permissions
# ==================================================

echo
echo "[6/7] Fixing executable permissions..."

[ -f "$HOME/.config/bspwm/bspwmrc" ] && \
    chmod +x "$HOME/.config/bspwm/bspwmrc"

[ -f "$HOME/.config/sxhkd/sxhkdrc" ] && \
    chmod +x "$HOME/.config/sxhkd/sxhkdrc"

# ==================================================
# Reload
# ==================================================

echo
echo "[7/7] Reloading bspwm..."

if command -v bspc >/dev/null 2>&1; then
    bspc wm -r 2>/dev/null || true
fi

if command -v sxhkd >/dev/null 2>&1; then
    pkill -USR1 -x sxhkd 2>/dev/null || true
fi

echo
echo "====================================="
echo "       Installation Complete!"
echo "====================================="
echo
echo "Please log out and log back in."
echo

read -rp "Restart system now? [y/N]: " reboot_choice

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