#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_step() {
    echo -e "${BLUE}🚀 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_step "Setting up your Ubuntu machine with Nix + Home Manager..."
echo ""

# Check if we're on Ubuntu/Debian
if ! command -v apt &> /dev/null; then
    print_error "This script is designed for Ubuntu/Debian systems with apt package manager"
    exit 1
fi

# Install essential system dependencies
print_step "Installing system dependencies..."
sudo apt update -y
sudo apt install -y curl git xz-utils ca-certificates snapd flatpak gnome-software-plugin-flatpak

print_success "System dependencies installed"

# Clone the setup repository
print_step "Downloading setup configuration..."
if [ -d "$HOME/.setup" ]; then
    print_warning "Setup directory already exists, updating..."
    cd "$HOME/.setup"
    git pull
else
    git clone https://github.com/rlcurrall/setup.git "$HOME/.setup"
    cd "$HOME/.setup"
fi

print_success "Setup configuration downloaded"

# Install Nix if not already installed
if [ ! -d "/nix" ]; then
    print_step "Installing Nix package manager..."
    curl -L https://nixos.org/nix/install | sh
    print_success "Nix installed successfully"
else
    print_success "Nix already installed"
fi

# Source Nix environment
if [ -f ~/.nix-profile/etc/profile.d/nix.sh ]; then
    . ~/.nix-profile/etc/profile.d/nix.sh
    print_success "Nix environment loaded"
else
    print_error "Nix profile not found. Please restart your shell and run this script again."
    exit 1
fi

# Configure Nix with flakes
print_step "Configuring Nix with flakes support..."
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf
print_success "Flakes enabled"

# Apply Home Manager configuration
print_step "Applying Home Manager configuration..."
cd ~/.setup/linux
nix run home-manager/master -- switch --flake .#robb
print_success "Home Manager configuration applied successfully!"

# Install GUI applications that can't be handled by Nix
print_step "Installing essential GUI applications..."

# Setup Flatpak
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Install via snap (better desktop integration)
sudo snap install ghostty --classic || print_warning "Failed to install Ghostty via snap"
sudo snap install discord --classic || print_warning "Failed to install Discord via snap"
sudo snap install code --classic || print_warning "Failed to install VS Code via snap"

# Install via flatpak
flatpak install -y flathub com.vivaldi.Vivaldi || print_warning "Failed to install Vivaldi via flatpak"
flatpak install -y flathub org.localsend.localsend_app || print_warning "Failed to install LocalSend via flatpak"

echo ""
print_success "Setup complete!"
echo ""
echo "Next steps:"
echo "1. Restart your shell or run: source ~/.nix-profile/etc/profile.d/nix.sh"
echo "2. Your development tools are now managed by Home Manager"
echo "3. To update your configuration: edit ~/.setup/linux/flake.nix and run 'rebuild'"
echo "4. Install any additional GUI apps you need via apt/snap/flatpak"
echo ""
echo "🚀 Happy coding!"