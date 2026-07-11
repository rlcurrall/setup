#!/bin/bash

set -e

# Prerequisites:
# Before running this script, make sure you have:
#   1. Installed Xcode Command Line Tools:
#        xcode-select --install
#   2. Cloned the dotfiles repository to ~/.setup:
#        git clone https://github.com/rlcurrall/setup ~/.setup

printf "\n🚀 Setting up your Mac with Nix + nix-darwin + Home Manager...\n\n"

# Install Nix if not already installed
if [ ! -d "/nix" ]; then
    printf "🔧 Installing Lix package manager...\n"
    curl -sSf -L https://install.lix.systems/lix | sh -s -- install
    printf "✅ Lix installed successfully\n"
else
    printf "✅ Nix already installed\n"
fi

# Source Nix environment (Determinate multi-user daemon first, then single-user fallback)
if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    printf "✅ Nix environment loaded (multi-user daemon)\n"
elif [ -f ~/.nix-profile/etc/profile.d/nix.sh ]; then
    . ~/.nix-profile/etc/profile.d/nix.sh
    printf "✅ Nix environment loaded (single-user)\n"
else
    printf "❌ Nix profile not found. Please restart your shell and run this script again.\n"
    exit 1
fi

# Install Homebrew if not already installed (required by nix-darwin's homebrew module)
if ! [ -x /opt/homebrew/bin/brew ]; then
    printf "🍺 Installing Homebrew...\n"
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
    printf "✅ Homebrew installed successfully\n"
else
    printf "✅ Homebrew already installed\n"
fi

# Install nix-darwin and apply configuration
printf "🍎 Installing nix-darwin and applying configuration...\n"
cd ~/.setup/mac
sudo nix run nix-darwin/master#darwin-rebuild --extra-experimental-features "flakes nix-command" -- switch --flake .#helheim
printf "✅ nix-darwin configuration applied successfully!\n"

printf "\n🎉 Setup complete!\n\n"
printf "Next steps:\n"
printf "1. Restart your shell (recommended) or re-source the Nix env\n"
printf "2. Your development tools are now managed by Nix\n"
printf "3. To update your configuration: edit ~/.setup/mac/flake.nix and run 'rebuild'\n"
printf "4. Homebrew apps will be installed automatically on next rebuild\n\n"
printf "Happy coding! 🚀\n"