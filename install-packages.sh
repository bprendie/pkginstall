#!/bin/bash

# Auto-generated installation script for Arch Linux packages
# Generated on: Tue Nov 25 02:00:03 PM EST 2025
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
OFFICIAL_PACKAGES=(
  '1password-beta'
  '1password-cli'
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

AUR_PACKAGES=(
  '3270-fonts'
  'ibm-fonts'
)
# Detect AUR helper
AUR_HELPER=""
if command -v yay >/dev/null 2>&1; then
    AUR_HELPER="yay"
elif command -v paru >/dev/null 2>&1; then
    AUR_HELPER="paru"
fi

# Install official repository packages
if [[ ${#OFFICIAL_PACKAGES[@]} -gt 0 ]]; then
    info "Installing official repository packages (${#OFFICIAL_PACKAGES[@]} total)..."
    if [[ "$DRY_RUN" == "true" ]]; then
        MISSING_COUNT=0
        INSTALLED_COUNT=0
        for pkg in "${OFFICIAL_PACKAGES[@]}"; do
            if pacman -Q "$pkg" >/dev/null 2>&1; then
                echo "  ✓ $pkg (already installed)"
                let INSTALLED_COUNT=INSTALLED_COUNT+1 || true
            else
                echo "  → $pkg (would install)"
                let MISSING_COUNT=MISSING_COUNT+1 || true
            fi
        done
        echo ""
        info "Official packages: $INSTALLED_COUNT already installed, $MISSING_COUNT would be installed"
        dry_run "Would run: pacman -S --noconfirm ${OFFICIAL_PACKAGES[*]}"
    else
        pacman -S --noconfirm "${OFFICIAL_PACKAGES[@]}" || {
            error "Some official packages failed to install. Attempting individual installation..."
            for pkg in "${OFFICIAL_PACKAGES[@]}"; do
                if ! pacman -Q "$pkg" >/dev/null 2>&1; then
                    info "Installing $pkg..."
                    pacman -S --noconfirm "$pkg" || warn "Failed to install $pkg"
                fi
            done
        }
    fi
else
    info "No official repository packages to install"
fi

# Install AUR packages
if [[ ${#AUR_PACKAGES[@]} -gt 0 ]]; then
    if [[ -z "$AUR_HELPER" ]]; then
        warn "AUR packages found but no AUR helper (yay/paru) is installed"
        warn "AUR packages (${#AUR_PACKAGES[@]} total) that need manual installation:"
        for pkg in "${AUR_PACKAGES[@]}"; do
            echo "  - $pkg"
        done
        warn "Install an AUR helper first:"
        warn "  yay: https://github.com/Jguer/yay"
        warn "  paru: https://github.com/Morganamilo/paru"
    else
        info "Installing AUR packages (${#AUR_PACKAGES[@]} total) using $AUR_HELPER..."
        if [[ "$DRY_RUN" == "true" ]]; then
            MISSING_COUNT=0
            INSTALLED_COUNT=0
            for pkg in "${AUR_PACKAGES[@]}"; do
                if pacman -Q "$pkg" >/dev/null 2>&1; then
                    echo "  ✓ $pkg (already installed)"
                    let INSTALLED_COUNT=INSTALLED_COUNT+1 || true
                else
                    echo "  → $pkg (would install from AUR)"
                    let MISSING_COUNT=MISSING_COUNT+1 || true
                fi
            done
            echo ""
            info "AUR packages: $INSTALLED_COUNT already installed, $MISSING_COUNT would be installed"
            dry_run "Would run: $AUR_HELPER -S --noconfirm --needed ${AUR_PACKAGES[*]}"
        else
            # Note: AUR helpers typically don't need root, but we check anyway
            if [[ $EUID -eq 0 ]]; then
                # Try to find a non-root user to run AUR helper
                REGULAR_USER=""
                if [[ -n "${SUDO_USER:-}" ]]; then
                    REGULAR_USER="${SUDO_USER}"
                elif [[ -n "${USER:-}" ]] && [[ "$USER" != "root" ]]; then
                    REGULAR_USER="${USER}"
                else
                    # Try to find the first regular user with a home directory
                    for possible_user in $(getent passwd | awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' | head -1); do
                        if [[ -n "$possible_user" ]]; then
                            REGULAR_USER="$possible_user"
                            break
                        fi
                    done
                fi
                
                if [[ -n "$REGULAR_USER" ]]; then
                    info "Installing AUR packages as user: $REGULAR_USER"
                    sudo -u "$REGULAR_USER" $AUR_HELPER -S --noconfirm --needed "${AUR_PACKAGES[@]}" || {
                        error "Some AUR packages failed to install. Attempting individual installation..."
                        for pkg in "${AUR_PACKAGES[@]}"; do
                            if ! pacman -Q "$pkg" >/dev/null 2>&1; then
                                info "Installing $pkg from AUR..."
                                sudo -u "$REGULAR_USER" $AUR_HELPER -S --noconfirm --needed "$pkg" || warn "Failed to install $pkg"
                            fi
                        done
                    }
                else
                    warn "Could not determine non-root user. Installing AUR packages as root (not recommended)..."
                    warn "Consider running this script with sudo instead of as root directly"
                    $AUR_HELPER -S --noconfirm --needed "${AUR_PACKAGES[@]}" || {
                        error "Some AUR packages failed to install. Attempting individual installation..."
                        for pkg in "${AUR_PACKAGES[@]}"; do
                            if ! pacman -Q "$pkg" >/dev/null 2>&1; then
                                info "Installing $pkg from AUR..."
                                $AUR_HELPER -S --noconfirm --needed "$pkg" || warn "Failed to install $pkg"
                            fi
                        done
                    }
                fi
            else
                # Running as regular user (shouldn't happen in normal flow, but handle it)
                info "Installing AUR packages as current user..."
                $AUR_HELPER -S --noconfirm --needed "${AUR_PACKAGES[@]}" || {
                    error "Some AUR packages failed to install. Attempting individual installation..."
                    for pkg in "${AUR_PACKAGES[@]}"; do
                        if ! pacman -Q "$pkg" >/dev/null 2>&1; then
                            info "Installing $pkg from AUR..."
                            $AUR_HELPER -S --noconfirm --needed "$pkg" || warn "Failed to install $pkg"
                        fi
                    done
                }
            fi
        fi
    fi
else
    info "No AUR packages to install"
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
