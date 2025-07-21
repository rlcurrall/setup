#!/bin/bash

# ##############################################################################
# install.sh
#
# todo...
#
# ##############################################################################

set -e

# Check if we're in the right directory
if [ ! -f "flake.nix" ]; then
    echo "❌ Error: flake.nix not found. Please run this script from ~/.setup/linux/"
    exit 1
fi

# Check if Nix is installed
if ! command -v nix &> /dev/null; then
    echo "🔧 Nix not found. Installing Nix first..."

    # Install minimal system dependencies
    sudo apt update -y
    sudo apt install -y curl git xz-utils ca-certificates

    # Install Nix
    curl -L https://nixos.org/nix/install | sh

    # Source Nix environment
    if [ -f ~/.nix-profile/etc/profile.d/nix.sh ]; then
        . ~/.nix-profile/etc/profile.d/nix.sh
    else
        echo "❌ Nix installation failed. Please restart your shell and try again."
        exit 1
    fi

    # Configure flakes
    mkdir -p ~/.config/nix
    echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf
fi

# Run the installation app from the flake
echo "🚀 Running installation via Nix flake..."
nix run .#install
