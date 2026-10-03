#!/bin/bash

set -e

# Infer the profile from the account, or accept an explicit selection.
MAC_PROFILE="${1:-}"
if [ -z "$MAC_PROFILE" ]; then
    case "$(id -un)" in
        robb) MAC_PROFILE=personal ;;
        robcurrall) MAC_PROFILE=work ;;
        *) printf 'Usage: bash mac/install.sh personal|work\n' >&2; exit 1 ;;
    esac
fi
case "$MAC_PROFILE" in
    personal) EXPECTED_USER=robb ;;
    work) EXPECTED_USER=robcurrall ;;
    *) printf 'Unknown profile: %s (expected personal or work)\n' "$MAC_PROFILE" >&2; exit 1 ;;
esac
if [ "$(id -un)" != "$EXPECTED_USER" ]; then
    printf 'Profile %s requires account %s; run this installer as that user.\n' "$MAC_PROFILE" "$EXPECTED_USER" >&2
    exit 1
fi

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
sudo nix run nix-darwin/master#darwin-rebuild --extra-experimental-features "flakes nix-command" -- switch --flake ".#$MAC_PROFILE"
printf "✅ nix-darwin configuration applied successfully!\n"

printf "\n🎉 Setup complete!\n\n"
printf "Next steps:\n"
printf "1. Restart your shell (recommended) or re-source the Nix env\n"
printf "2. Your development tools are now managed by Nix\n"
printf "3. To update your configuration: edit ~/.setup/mac/flake.nix and run 'rebuild'\n"
printf "4. Homebrew apps will be installed automatically on next rebuild\n\n"
printf "Happy coding! 🚀\n"