#!/bin/bash

# Auto-generated installation script for Arch Linux packages
# Generated on: Tue Nov 25 10:57:26 AM EST 2025
# 
# This script installs all user-installed packages and restores
# custom ModemManager/WWAN configurations
#
# Usage: ./install-packages.sh [--dry-run]

set -euo pipefail

# Parse arguments
DRY_RUN=false
if [[ "${1:-}" == "--dry-run" ]] || [[ "${1:-}" == "-n" ]]; then
    DRY_RUN=true
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored output
info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

dry_run() {
    echo -e "${CYAN}[DRY-RUN]${NC} $1"
}

# Check if running as root (unless dry-run)
if [[ "$DRY_RUN" == "false" ]] && [[ $EUID -ne 0 ]]; then
   error "This script must be run as root (unless using --dry-run)"
   exit 1
fi

if [[ "$DRY_RUN" == "true" ]]; then
    info "DRY RUN MODE - No changes will be made"
    echo ""
fi

info "Starting package installation..."

# Update package database
if [[ "$DRY_RUN" == "true" ]]; then
    dry_run "Would run: pacman -Sy"
else
    info "Updating package database..."
    pacman -Sy
fi

# Install packages
info "Installing user packages..."
PACKAGES=(
  '1password-beta'
  '1password-cli'
  '3270-fonts'
  'aether'
  'alacritty'
  'asdcontrol'
  'bash-completion'
  'bat'
  'bluetui'
  'bridge-utils'
  'brightnessctl'
  'btop'
  'btrfs-progs'
  'clang'
  'cups'
  'cups-browsed'
  'cups-filters'
  'cups-pdf'
  'cursor-bin'
  'cursor-cli'
  'dnsmasq'
  'docker'
  'docker-buildx'
  'docker-compose'
  'dust'
  'efibootmgr'
  'evince'
  'exfatprogs'
  'expac'
  'eza'
  'fastfetch'
  'fcitx5'
  'fcitx5-gtk'
  'fcitx5-qt'
  'fd'
  'ffmpegthumbnailer'
  'fontconfig'
  'freerdp'
  'freerdp2'
  'fzf'
  'ghostty'
  'git'
  'github-cli'
  'gnome-calculator'
  'gnome-disk-utility'
  'gnome-keyring'
  'gnome-themes-extra'
  'gpu-screen-recorder'
  'grim'
  'gst-plugin-pipewire'
  'gum'
  'gvfs-mtp'
  'gvfs-nfs'
  'gvfs-smb'
  'hypridle'
  'hyprland'
  'hyprland-guiutils'
  'hyprlock'
  'hyprpicker'
  'hyprsunset'
  'ibm-fonts'
  'imagemagick'
  'impala'
  'imv'
  'inetutils'
  'intel-ucode'
  'inxi'
  'iwd'
  'jq'
  'kdenlive'
  'kvantum-qt5'
  'lazydocker'
  'lazygit'
  'less'
  'libpulse'
  'libqalculate'
  'libreoffice-fresh'
  'libyaml'
  'limine'
  'limine-mkinitcpio-hook'
  'limine-snapper-sync'
  'linux'
  'linux-firmware'
  'llvm'
  'localsend'
  'luarocks'
  'mako'
  'man-db'
  'mariadb-libs'
  'mise'
  'modemmanager'
  'mpv'
  'nano'
  'nautilus'
  'neovim'
  'network-manager-applet'
  'networkmanager'
  'nm-connection-editor'
  'noto-fonts'
  'noto-fonts-cjk'
  'noto-fonts-emoji'
  'noto-fonts-extra'
  'nss-mdns'
  'obs-studio'
  'obsidian'
  'omarchy-chromium'
  'omarchy-keyring'
  'omarchy-nvim'
  'omarchy-walker'
  'openbsd-netcat'
  'pamixer'
  'pinta'
  'pipewire'
  'pipewire-alsa'
  'pipewire-jack'
  'pipewire-pulse'
  'playerctl'
  'plocate'
  'plymouth'
  'polkit-gnome'
  'postgresql-libs'
  'power-profiles-daemon'
  'python-gobject'
  'python-poetry-core'
  'python-terminaltexteffects'
  'qt5-wayland'
  'remmina'
  'ripgrep'
  'rsync'
  'ruby'
  'rust'
  'satty'
  'sddm'
  'signal-desktop'
  'slurp'
  'snapper'
  'sof-firmware'
  'spotify'
  'sshfs'
  'starship'
  'steam'
  'sushi'
  'swaybg'
  'swayosd'
  'system-config-printer'
  'tldr'
  'tobi-try'
  'tree-sitter-cli'
  'ttf-cascadia-mono-nerd'
  'ttf-ia-writer'
  'ttf-ibm-plex'
  'ttf-jetbrains-mono-nerd'
  'ttf-meslo-nerd'
  'typora'
  'tzupdate'
  'ufw'
  'ufw-docker'
  'unzip'
  'usage'
  'usbutils'
  'uwsm'
  'vde2'
  'virt-manager'
  'virt-viewer'
  'visual-studio-code-bin'
  'waybar'
  'wayfreeze'
  'whois'
  'wireless-regdb'
  'wiremix'
  'wireplumber'
  'wl-clipboard'
  'woff2-font-awesome'
  'wpa_supplicant'
  'xdg-desktop-portal-gtk'
  'xdg-desktop-portal-hyprland'
  'xdg-terminal-exec'
  'xmlstarlet'
  'xournalpp'
  'yaru-icon-theme'
  'yay'
  'yazi'
  'yt-dlp'
  'zoxide'
  'zram-generator'
)
# Install all packages at once for better dependency resolution
if [[ "$DRY_RUN" == "true" ]]; then
    info "Packages that would be installed (${#PACKAGES[@]} total):"
    MISSING_COUNT=0
    INSTALLED_COUNT=0
    for pkg in "${PACKAGES[@]}"; do
        if pacman -Q "$pkg" >/dev/null 2>&1; then
            echo "  ✓ $pkg (already installed)"
            let INSTALLED_COUNT=INSTALLED_COUNT+1 || true
        else
            echo "  → $pkg (would install)"
            let MISSING_COUNT=MISSING_COUNT+1 || true
        fi
    done
    echo ""
    info "Summary: $INSTALLED_COUNT already installed, $MISSING_COUNT would be installed"
    dry_run "Would run: pacman -S --noconfirm ${PACKAGES[*]}"
else
    pacman -S --noconfirm "${PACKAGES[@]}" || {
        error "Some packages failed to install. Attempting individual installation..."
        for pkg in "${PACKAGES[@]}"; do
            if ! pacman -Q "$pkg" >/dev/null 2>&1; then
                info "Installing $pkg..."
                pacman -S --noconfirm "$pkg" || warn "Failed to install $pkg"
            fi
        done
    }
fi

info "Package installation completed!"

# Setup ModemManager/WWAN configuration
info "Setting up ModemManager/WWAN configuration..."

# Create ModemManager config directories if they don't exist
if [[ "$DRY_RUN" == "true" ]]; then
    for dir in /etc/ModemManager/connection.d /etc/ModemManager/fcc-unlock.d /etc/ModemManager/modem-setup.d; do
        if [[ -d "$dir" ]]; then
            dry_run "Directory exists: $dir"
        else
            dry_run "Would create directory: $dir"
        fi
    done
else
    mkdir -p /etc/ModemManager/connection.d
    mkdir -p /etc/ModemManager/fcc-unlock.d
    mkdir -p /etc/ModemManager/modem-setup.d
fi

# Create WWAN network configuration
if [[ "$DRY_RUN" == "true" ]]; then
    info "WWAN network configuration that would be created:"
    echo ""
    echo "  File: /etc/systemd/network/20-wwan.network"
    echo "  Content:"
    cat << 'WWAN_CONFIG_EOF' | sed 's/^/    /'
    [Match]
    Name=ww*
    
    [Link]
    RequiredForOnline=routable
    
    [Network]
    DHCP=yes
    
    # systemd-networkd does not set per-interface-type default route metrics
    # https://github.com/systemd/systemd/issues/17698
    # Explicitly set route metric, so that Ethernet is preferred over Wi-Fi and Wi-Fi is preferred over mobile broadband.
    # Use values from NetworkManager. From nm_device_get_route_metric_default in
    # https://gitlab.freedesktop.org/NetworkManager/NetworkManager/-/blob/main/src/core/devices/nm-device.c
    [DHCPv4]
    RouteMetric=700
    
    [IPv6AcceptRA]
    RouteMetric=700
WWAN_CONFIG_EOF
    echo ""
    if [[ -f /etc/systemd/network/20-wwan.network ]]; then
        warn "File already exists. Would overwrite it."
    else
        dry_run "Would create: /etc/systemd/network/20-wwan.network"
    fi
else
    info "Creating WWAN network configuration..."
    cat > /etc/systemd/network/20-wwan.network << 'WWAN_CONFIG_EOF'
[Match]
Name=ww*

[Link]
RequiredForOnline=routable

[Network]
DHCP=yes

# systemd-networkd does not set per-interface-type default route metrics
# https://github.com/systemd/systemd/issues/17698
# Explicitly set route metric, so that Ethernet is preferred over Wi-Fi and Wi-Fi is preferred over mobile broadband.
# Use values from NetworkManager. From nm_device_get_route_metric_default in
# https://gitlab.freedesktop.org/NetworkManager/NetworkManager/-/blob/main/src/core/devices/nm-device.c
[DHCPv4]
RouteMetric=700

[IPv6AcceptRA]
RouteMetric=700
WWAN_CONFIG_EOF
fi

# Ensure systemd-networkd is enabled if using it
if [[ "$DRY_RUN" == "true" ]]; then
    if systemctl is-enabled systemd-networkd.service >/dev/null 2>&1; then
        dry_run "systemd-networkd.service is already enabled"
    elif systemctl is-enabled NetworkManager.service >/dev/null 2>&1; then
        dry_run "NetworkManager.service is already enabled"
    else
        warn "Neither systemd-networkd nor NetworkManager appears to be enabled"
        dry_run "Would need to enable one of them manually"
    fi
else
    if systemctl is-enabled systemd-networkd.service >/dev/null 2>&1 || \
       systemctl is-enabled NetworkManager.service >/dev/null 2>&1; then
        info "Network services are configured"
    else
        warn "Neither systemd-networkd nor NetworkManager appears to be enabled"
        warn "You may need to enable one of them:"
        warn "  systemctl enable systemd-networkd.service"
        warn "  OR"
        warn "  systemctl enable NetworkManager.service"
    fi
fi

# Ensure ModemManager is enabled
if [[ "$DRY_RUN" == "true" ]]; then
    if pacman -Q modemmanager >/dev/null 2>&1; then
        if systemctl is-enabled ModemManager.service >/dev/null 2>&1; then
            dry_run "ModemManager.service is already enabled"
        else
            dry_run "Would enable ModemManager.service"
        fi
    else
        warn "ModemManager is not installed. Would need to install it with: pacman -S modemmanager"
    fi
else
    if pacman -Q modemmanager >/dev/null 2>&1; then
        info "Enabling ModemManager service..."
        systemctl enable ModemManager.service || warn "Failed to enable ModemManager"
    else
        warn "ModemManager is not installed. Install it with: pacman -S modemmanager"
    fi
fi

if [[ "$DRY_RUN" == "true" ]]; then
    info ""
    info "Dry run completed! No changes were made."
    info "To actually apply these changes, run without --dry-run:"
    info "  sudo ./install-packages.sh"
else
    info "Installation script completed successfully!"
    info ""
    info "Next steps:"
    info "  1. Review the installed packages"
    info "  2. Restart network services if needed: systemctl restart systemd-networkd"
    info "  3. Check ModemManager status: systemctl status ModemManager"
fi
