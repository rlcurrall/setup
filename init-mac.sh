#!/bin/bash

# Bootstrap a fresh Mac end-to-end.
#
# One-liner:
#   curl -fsSL https://raw.githubusercontent.com/rlcurrall/setup/main/init-mac.sh | bash
#
# This script handles the prerequisites that mac/install.sh assumes
# (Xcode CLT, repo clone), then hands off to install.sh,
# which installs Nix + Homebrew and applies the nix-darwin flake.

set -e

printf "\n🚀 Bootstrap for a fresh Mac\n\n"

# 1. Xcode Command Line Tools (required for git and many build tools)
if ! xcode-select -p &>/dev/null; then
    printf "🔧 Installing Xcode Command Line Tools...\n"
    printf "   A system dialog will appear — click 'Install' and accept the license.\n"
    xcode-select --install
    printf "   Waiting for installation to complete...\n"
    until xcode-select -p &>/dev/null; do sleep 5; done
    printf "✅ Xcode CLT installed\n"
else
    printf "✅ Xcode CLT already installed\n"
fi

# 2. Clone the dotfiles repo
if [ ! -d ~/.setup ]; then
    printf "📦 Cloning dotfiles to ~/.setup...\n"
    git clone https://github.com/rlcurrall/setup ~/.setup
    printf "✅ Dotfiles cloned\n"
else
    printf "✅ Dotfiles already present at ~/.setup\n"
fi

# 3. Hand off to the main installer
printf "\n👉 Handing off to ~/.setup/mac/install.sh...\n\n"
exec bash ~/.setup/mac/install.sh "$@"
