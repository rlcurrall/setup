#!/bin/bash
set -e

# This script bootstraps the declarative Ubuntu setup.
# It can be run directly from GitHub:
# wget -O - https://raw.githubusercontent.com/rlcurrall/setup/main/ubuntu/install.sh | bash

print_step() {
    echo -e "\n🚀 $1"
}

# 0. Install essential dependencies
# We need git to clone the repo and curl to download installers.
print_step "Installing essential dependencies (git, curl)..."
sudo apt-get update -y
sudo apt-get install -y git curl

# 1. Install Nix
if ! command -v nix &> /dev/null; then
    if [ -f "/nix/receipt.json" ]; then
        echo "⚠️  Nix installation appears incomplete (receipt found but nix command unavailable)"
        echo "    Please restart your shell or run: source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh"
        exit 1
    else
        print_step "Installing Nix package manager..."
        # Using the Determinate Systems installer for its reliability and speed.
        curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
        # Source the nix profile to make the 'nix' command available in this script session.
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    fi
else
    echo "✅ Nix is already installed."
    # Source the nix profile in case it's not in current session
    if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    fi
fi

# 2. Enable Flakes (idempotent)
print_step "Enabling Nix Flakes support..."
mkdir -p "$HOME/.config/nix"
# Check if the feature is already enabled to avoid unnecessary writes
if ! grep -q "experimental-features = nix-command flakes" "$HOME/.config/nix/nix.conf" 2>/dev/null; then
    echo "experimental-features = nix-command flakes" >> "$HOME/.config/nix/nix.conf"
fi

# 3. Clone or update the setup repository
SETUP_DIR="$HOME/.setup"
if [ ! -d "$SETUP_DIR" ]; then
    print_step "Cloning setup repository..."
    git clone https://github.com/rlcurrall/setup.git "$SETUP_DIR"
else
    print_step "Setup repository already exists. Checking if update is needed..."
    cd "$SETUP_DIR"
    if [ -d ".git" ]; then
        git pull
    else
        echo "⚠️  Directory exists but is not a git repository, continuing with existing files..."
    fi
fi

# 4. Run system setup for packages that can't be managed by Nix
print_step "Installing system packages and applications..."
cd "$SETUP_DIR/ubuntu"
chmod +x system-setup.sh
./system-setup.sh

# 5. Build the Home Manager configuration
print_step "Applying the declarative Home Manager configuration..."
nix run home-manager/master -- switch --flake .#robb

echo -e "\n✅ Setup complete! Please restart your shell or log out and back in for all changes to take effect."
