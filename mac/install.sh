#!/bin/bash

set -e

printf "\n🚀 Setting up your Mac with Nix + nix-darwin + Home Manager...\n\n"

# Install Nix if not already installed
if [ ! -d "/nix" ]; then
    printf "🔧 Installing Nix package manager (Determinate Systems installer)...\n"
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
    printf "✅ Nix installed successfully\n"
else
    printf "✅ Nix already installed\n"
fi

# Source Nix environment
if [ -f ~/.nix-profile/etc/profile.d/nix.sh ]; then
    . ~/.nix-profile/etc/profile.d/nix.sh
    printf "✅ Nix environment loaded\n"
else
    printf "❌ Nix profile not found. Please restart your shell and run this script again.\n"
    exit 1
fi

# Install nix-darwin and apply configuration
printf "🍎 Installing nix-darwin and applying configuration...\n"
cd ~/.setup/mac
sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake .#helheim
printf "✅ nix-darwin configuration applied successfully!\n"

printf "\n🎉 Setup complete!\n\n"
printf "Next steps:\n"
printf "1. Restart your shell or run: source ~/.nix-profile/etc/profile.d/nix.sh\n"
printf "2. Your development tools are now managed by Nix\n"
printf "3. To update your configuration: edit ~/.setup/mac/flake.nix and run 'rebuild'\n"
printf "4. Homebrew apps will be installed automatically on next rebuild\n\n"
printf "Happy coding! 🚀\n"