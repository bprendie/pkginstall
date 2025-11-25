# Arch Linux Package Installation Script Generator

This tool generates an installation script that can be used to replicate your Arch Linux package setup on a fresh system, including custom ModemManager/WWAN configurations.

## Usage

### Generate the Installation Script

Run the generator script on your current system:

```bash
./generate-install-script.sh
```

This will create `install-packages.sh` containing:
- All explicitly installed packages (excluding base/base-devel meta-packages)
- Custom WWAN network configuration (`/etc/systemd/network/20-wwan.network`)
- ModemManager setup instructions

### Use on a Fresh System

1. Copy `install-packages.sh` to your fresh Arch Linux system
2. (Optional) Test with dry-run first to see what would be installed:

```bash
./install-packages.sh --dry-run
```

3. Run it as root to actually install:

```bash
sudo ./install-packages.sh
```

The script will:
- Update the package database
- Install all your packages
- Set up ModemManager directories
- Create the WWAN network configuration
- Enable ModemManager service

### Dry Run Mode

Use `--dry-run` (or `-n`) to preview what the script would do without making any changes:

```bash
./install-packages.sh --dry-run
```

This will show:
- Which packages are already installed vs. which would be installed
- What configuration files would be created
- What services would be enabled
- A summary of all changes

Dry-run mode doesn't require root privileges.

## What Gets Included

### Packages
- All packages explicitly installed via `pacman -Qe`
- Excludes `base` and `base-devel` meta-packages (these are part of the base Arch installation)

### Configuration Files
- `/etc/systemd/network/20-wwan.network` - WWAN interface configuration with route metrics

### ModemManager Setup
- Creates necessary ModemManager config directories:
  - `/etc/ModemManager/connection.d/`
  - `/etc/ModemManager/fcc-unlock.d/`
  - `/etc/ModemManager/modem-setup.d/`

## Notes

- The script attempts to install all packages at once for better dependency resolution
- If bulk installation fails, it falls back to individual package installation
- The script checks for network service configuration (systemd-networkd or NetworkManager)
- ModemManager service will be enabled if the package is installed

## Regenerating

Run `generate-install-script.sh` again anytime to regenerate `install-packages.sh` with your current package list.
