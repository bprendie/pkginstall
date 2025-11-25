#!/bin/bash

# Script to generate an installation script for Arch Linux packages
# and system configurations

set -euo pipefail

OUTPUT_SCRIPT="install-packages.sh"
WWAN_CONFIG="/etc/systemd/network/20-wwan.network"
MODEM_MANAGER_DIR="/etc/ModemManager"

echo "Generating installation script..."

# Get all explicitly installed packages, excluding base and base-devel meta-packages
PACKAGES=$(pacman -Qe | awk '{print $1}' | grep -v "^base$" | grep -v "^base-devel$")

# Count packages
PACKAGE_COUNT=$(echo "$PACKAGES" | wc -l)
echo "Found $PACKAGE_COUNT user-installed packages"

# Separate packages into official repo and AUR packages
echo "Detecting AUR packages..."
OFFICIAL_PACKAGES=""
AUR_PACKAGES=""

# Update sync database to ensure we can check for packages
pacman -Sy >/dev/null 2>&1 || true

for pkg in $PACKAGES; do
    # For installed packages, check the Repository field directly
    if pacman -Qi "$pkg" >/dev/null 2>&1; then
        REPO=$(pacman -Qi "$pkg" 2>/dev/null | grep "^Repository" | awk '{print $3}' || echo "")
        if [[ "$REPO" == "aur" ]] || [[ "$REPO" == "local" ]]; then
            AUR_PACKAGES="${AUR_PACKAGES}${pkg}\n"
        else
            OFFICIAL_PACKAGES="${OFFICIAL_PACKAGES}${pkg}\n"
        fi
    else
        # Package not installed, check if it exists in sync database
        if pacman -Ss "^${pkg}$" 2>/dev/null | grep -qE "^[a-z].*/${pkg} "; then
            OFFICIAL_PACKAGES="${OFFICIAL_PACKAGES}${pkg}\n"
        else
            # Not in sync database, assume AUR
            AUR_PACKAGES="${AUR_PACKAGES}${pkg}\n"
        fi
    fi
done

# Remove trailing newlines
OFFICIAL_PACKAGES=$(echo -e "$OFFICIAL_PACKAGES" | grep -v '^$')
AUR_PACKAGES=$(echo -e "$AUR_PACKAGES" | grep -v '^$')

OFFICIAL_COUNT=$(echo "$OFFICIAL_PACKAGES" | grep -v '^$' | wc -l)
AUR_COUNT=$(echo "$AUR_PACKAGES" | grep -v '^$' | wc -l)

echo "Found $OFFICIAL_COUNT official repository packages"
echo "Found $AUR_COUNT AUR packages"

# Show AUR packages if any were detected
if [[ $AUR_COUNT -gt 0 ]]; then
    echo ""
    echo "AUR packages detected:"
    echo "$AUR_PACKAGES" | while read -r pkg; do
        [[ -n "$pkg" ]] && echo "  - $pkg"
    done
    echo ""
fi

# Detect AUR helper
AUR_HELPER=""
if command -v yay >/dev/null 2>&1; then
    AUR_HELPER="yay"
elif command -v paru >/dev/null 2>&1; then
    AUR_HELPER="paru"
else
    echo "Warning: No AUR helper (yay/paru) found. AUR packages will need manual installation."
fi

if [[ -n "$AUR_HELPER" ]]; then
    echo "Using AUR helper: $AUR_HELPER"
fi

# Create the install script header
cat > "$OUTPUT_SCRIPT" << SCRIPT_HEADER
#!/bin/bash

# Auto-generated installation script for Arch Linux packages
# Generated on: $(date)
# 
# This script installs all user-installed packages and restores
# custom ModemManager/WWAN configurations
#
# Usage: ./install-packages.sh [--dry-run]

set -euo pipefail

# Parse arguments
DRY_RUN=false
if [[ "\${1:-}" == "--dry-run" ]] || [[ "\${1:-}" == "-n" ]]; then
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
    echo -e "\${GREEN}[INFO]\${NC} \$1"
}

warn() {
    echo -e "\${YELLOW}[WARN]\${NC} \$1"
}

error() {
    echo -e "\${RED}[ERROR]\${NC} \$1"
}

dry_run() {
    echo -e "\${CYAN}[DRY-RUN]\${NC} \$1"
}

# Check if running as root (unless dry-run)
if [[ "\$DRY_RUN" == "false" ]] && [[ \$EUID -ne 0 ]]; then
   error "This script must be run as root (unless using --dry-run)"
   exit 1
fi

if [[ "\$DRY_RUN" == "true" ]]; then
    info "DRY RUN MODE - No changes will be made"
    echo ""
fi

info "Starting package installation..."

# Update package database
if [[ "\$DRY_RUN" == "true" ]]; then
    dry_run "Would run: pacman -Sy"
else
    info "Updating package database..."
    pacman -Sy
fi

# Install packages
info "Installing user packages..."
SCRIPT_HEADER

# Add official package list as an array
echo "OFFICIAL_PACKAGES=(" >> "$OUTPUT_SCRIPT"
if [[ -n "$OFFICIAL_PACKAGES" ]]; then
    echo "$OFFICIAL_PACKAGES" | while read -r pkg; do
        [[ -n "$pkg" ]] && echo "  '$pkg'" >> "$OUTPUT_SCRIPT"
    done
fi
echo ")" >> "$OUTPUT_SCRIPT"

# Add AUR package list as an array
echo "" >> "$OUTPUT_SCRIPT"
echo "AUR_PACKAGES=(" >> "$OUTPUT_SCRIPT"
if [[ -n "$AUR_PACKAGES" ]]; then
    echo "$AUR_PACKAGES" | while read -r pkg; do
        [[ -n "$pkg" ]] && echo "  '$pkg'" >> "$OUTPUT_SCRIPT"
    done
fi
echo ")" >> "$OUTPUT_SCRIPT"

# Detect AUR helper in generated script
cat >> "$OUTPUT_SCRIPT" << 'AUR_HELPER_DETECT'
# Detect AUR helper
AUR_HELPER=""
if command -v yay >/dev/null 2>&1; then
    AUR_HELPER="yay"
elif command -v paru >/dev/null 2>&1; then
    AUR_HELPER="paru"
fi
AUR_HELPER_DETECT

# Add package installation commands
cat >> "$OUTPUT_SCRIPT" << INSTALL_PACKAGES

# Install official repository packages
if [[ \${#OFFICIAL_PACKAGES[@]} -gt 0 ]]; then
    info "Installing official repository packages (\${#OFFICIAL_PACKAGES[@]} total)..."
    if [[ "\$DRY_RUN" == "true" ]]; then
        MISSING_COUNT=0
        INSTALLED_COUNT=0
        for pkg in "\${OFFICIAL_PACKAGES[@]}"; do
            if pacman -Q "\$pkg" >/dev/null 2>&1; then
                echo "  ✓ \$pkg (already installed)"
                let INSTALLED_COUNT=INSTALLED_COUNT+1 || true
            else
                echo "  → \$pkg (would install)"
                let MISSING_COUNT=MISSING_COUNT+1 || true
            fi
        done
        echo ""
        info "Official packages: \$INSTALLED_COUNT already installed, \$MISSING_COUNT would be installed"
        dry_run "Would run: pacman -S --noconfirm \${OFFICIAL_PACKAGES[*]}"
    else
        pacman -S --noconfirm "\${OFFICIAL_PACKAGES[@]}" || {
            error "Some official packages failed to install. Attempting individual installation..."
            for pkg in "\${OFFICIAL_PACKAGES[@]}"; do
                if ! pacman -Q "\$pkg" >/dev/null 2>&1; then
                    info "Installing \$pkg..."
                    pacman -S --noconfirm "\$pkg" || warn "Failed to install \$pkg"
                fi
            done
        }
    fi
else
    info "No official repository packages to install"
fi

# Install AUR packages
if [[ \${#AUR_PACKAGES[@]} -gt 0 ]]; then
    if [[ -z "\$AUR_HELPER" ]]; then
        warn "AUR packages found but no AUR helper (yay/paru) is installed"
        warn "AUR packages (\${#AUR_PACKAGES[@]} total) that need manual installation:"
        for pkg in "\${AUR_PACKAGES[@]}"; do
            echo "  - \$pkg"
        done
        warn "Install an AUR helper first:"
        warn "  yay: https://github.com/Jguer/yay"
        warn "  paru: https://github.com/Morganamilo/paru"
    else
        info "Installing AUR packages (\${#AUR_PACKAGES[@]} total) using \$AUR_HELPER..."
        if [[ "\$DRY_RUN" == "true" ]]; then
            MISSING_COUNT=0
            INSTALLED_COUNT=0
            for pkg in "\${AUR_PACKAGES[@]}"; do
                if pacman -Q "\$pkg" >/dev/null 2>&1; then
                    echo "  ✓ \$pkg (already installed)"
                    let INSTALLED_COUNT=INSTALLED_COUNT+1 || true
                else
                    echo "  → \$pkg (would install from AUR)"
                    let MISSING_COUNT=MISSING_COUNT+1 || true
                fi
            done
            echo ""
            info "AUR packages: \$INSTALLED_COUNT already installed, \$MISSING_COUNT would be installed"
            dry_run "Would run: \$AUR_HELPER -S --noconfirm --needed \${AUR_PACKAGES[*]}"
        else
            # Note: AUR helpers typically don't need root, but we check anyway
            if [[ \$EUID -eq 0 ]]; then
                # Try to find a non-root user to run AUR helper
                REGULAR_USER=""
                if [[ -n "\${SUDO_USER:-}" ]]; then
                    REGULAR_USER="\${SUDO_USER}"
                elif [[ -n "\${USER:-}" ]] && [[ "\$USER" != "root" ]]; then
                    REGULAR_USER="\${USER}"
                else
                    # Try to find the first regular user with a home directory
                    for possible_user in \$(getent passwd | awk -F: '\$3 >= 1000 && \$1 != "nobody" {print \$1}' | head -1); do
                        if [[ -n "\$possible_user" ]]; then
                            REGULAR_USER="\$possible_user"
                            break
                        fi
                    done
                fi
                
                if [[ -n "\$REGULAR_USER" ]]; then
                    info "Installing AUR packages as user: \$REGULAR_USER"
                    sudo -u "\$REGULAR_USER" \$AUR_HELPER -S --noconfirm --needed "\${AUR_PACKAGES[@]}" || {
                        error "Some AUR packages failed to install. Attempting individual installation..."
                        for pkg in "\${AUR_PACKAGES[@]}"; do
                            if ! pacman -Q "\$pkg" >/dev/null 2>&1; then
                                info "Installing \$pkg from AUR..."
                                sudo -u "\$REGULAR_USER" \$AUR_HELPER -S --noconfirm --needed "\$pkg" || warn "Failed to install \$pkg"
                            fi
                        done
                    }
                else
                    warn "Could not determine non-root user. Installing AUR packages as root (not recommended)..."
                    warn "Consider running this script with sudo instead of as root directly"
                    \$AUR_HELPER -S --noconfirm --needed "\${AUR_PACKAGES[@]}" || {
                        error "Some AUR packages failed to install. Attempting individual installation..."
                        for pkg in "\${AUR_PACKAGES[@]}"; do
                            if ! pacman -Q "\$pkg" >/dev/null 2>&1; then
                                info "Installing \$pkg from AUR..."
                                \$AUR_HELPER -S --noconfirm --needed "\$pkg" || warn "Failed to install \$pkg"
                            fi
                        done
                    }
                fi
            else
                # Running as regular user (shouldn't happen in normal flow, but handle it)
                info "Installing AUR packages as current user..."
                \$AUR_HELPER -S --noconfirm --needed "\${AUR_PACKAGES[@]}" || {
                    error "Some AUR packages failed to install. Attempting individual installation..."
                    for pkg in "\${AUR_PACKAGES[@]}"; do
                        if ! pacman -Q "\$pkg" >/dev/null 2>&1; then
                            info "Installing \$pkg from AUR..."
                            \$AUR_HELPER -S --noconfirm --needed "\$pkg" || warn "Failed to install \$pkg"
                        fi
                    done
                }
            fi
        fi
    fi
else
    info "No AUR packages to install"
fi
INSTALL_PACKAGES

# Add WWAN config section
cat >> "$OUTPUT_SCRIPT" << 'SCRIPT_FOOTER'

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
SCRIPT_FOOTER

# Append the WWAN config content with indentation for dry-run display
cat "$WWAN_CONFIG" | sed 's/^/    /' >> "$OUTPUT_SCRIPT"

# Close the heredoc and add final instructions
cat >> "$OUTPUT_SCRIPT" << 'SCRIPT_END'
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
SCRIPT_END

# Append the WWAN config content again for actual creation
cat "$WWAN_CONFIG" >> "$OUTPUT_SCRIPT"

cat >> "$OUTPUT_SCRIPT" << 'SCRIPT_END2'
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
SCRIPT_END2

# Make the script executable
chmod +x "$OUTPUT_SCRIPT"

echo ""
echo "✓ Installation script generated: $OUTPUT_SCRIPT"
echo "  Contains $OFFICIAL_COUNT official repository packages"
echo "  Contains $AUR_COUNT AUR packages"
echo "  Includes WWAN network configuration"
if [[ -n "$AUR_HELPER" ]]; then
    echo "  AUR helper detected: $AUR_HELPER"
fi
echo ""

# Commit and push to GitHub if in a git repository
if git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Committing and pushing to GitHub..."
    
    # Stage the file (will add if not tracked)
    if git add "$OUTPUT_SCRIPT" 2>&1; then
        # Check if there are staged changes
        if ! git diff --cached --quiet "$OUTPUT_SCRIPT" 2>/dev/null; then
            # Commit the changes
            COMMIT_MSG="Update install-packages.sh (auto-generated on $(date +%Y-%m-%d))"
            if git commit -m "$COMMIT_MSG" 2>&1; then
                # Push to GitHub
                if git push 2>&1; then
                    echo "✓ Successfully pushed to GitHub"
                else
                    echo "  Warning: Failed to push to GitHub"
                    echo "  You may need to push manually: git push"
                fi
            else
                echo "  Warning: Failed to commit changes"
            fi
        else
            echo "  No changes detected in $OUTPUT_SCRIPT"
        fi
    else
        echo "  Warning: Failed to stage $OUTPUT_SCRIPT"
        echo "  Skipping git operations"
    fi
else
    echo "  Not in a git repository, skipping git operations"
fi

echo ""
echo "To use it on a fresh system, copy $OUTPUT_SCRIPT and run:"
echo "  sudo ./$OUTPUT_SCRIPT"
