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

print_step "Setting up your Arch Linux machine with Nix + Home Manager + Hyprland..."
echo ""
echo "🎨 Inspired by DHH's omarchy with your personal preferences"
echo ""


# Check if we're on Arch Linux
if ! command -v pacman &> /dev/null; then
    print_error "This script is designed for Arch Linux systems with pacman package manager"
    exit 1
fi

# Update system and install essential dependencies
print_step "Updating system and installing dependencies..."
sudo pacman -Syu --noconfirm
sudo pacman -S --noconfirm curl git xz ca-certificates base-devel

print_success "System dependencies installed"

# Install yay (AUR helper) if not present
if ! command -v yay &> /dev/null; then
    print_step "Installing yay AUR helper..."
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    cd /tmp/yay
    makepkg -si --noconfirm
    cd -
    rm -rf /tmp/yay
    print_success "yay AUR helper installed"
else
    print_success "yay already installed"
fi

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
    wget -qO- https://nixos.org/nix/install | sh -s -- --daemon
    print_success "Nix installed successfully"
else
    print_success "Nix already installed"
fi

# Source Nix environment
if [ -f /etc/profile.d/nix.sh ]; then
    . /etc/profile.d/nix.sh
    print_success "Nix environment loaded"
elif [ -f ~/.nix-profile/etc/profile.d/nix.sh ]; then
    . ~/.nix-profile/etc/profile.d/nix.sh
    print_success "Nix environment loaded"
else
    print_error "Nix profile not found. Please restart your shell and run this script again."
    exit 1
fi

# Configure Nix with flakes
print_step "Configuring Nix with flakes support..."
sudo mkdir -p /etc/nix
echo "experimental-features = nix-command flakes" | sudo tee /etc/nix/nix.conf
print_success "Flakes enabled system-wide"

# Apply Home Manager configuration
print_step "Applying Home Manager configuration..."
cd ~/.setup/arch
nix run home-manager/master -- switch --flake .#robb --extra-experimental-features "nix-command flakes"
print_success "Home Manager configuration applied successfully!"

# Install GUI applications via yay/AUR that work better outside Nix
print_step "Installing essential GUI applications via AUR..."

# Development tools
print_step "Installing development tools..."
yay -S --noconfirm visual-studio-code-bin || print_warning "Failed to install VS Code"
yay -S --noconfirm cursor-bin || print_warning "Failed to install Cursor" 
yay -S --noconfirm zed-bin || print_warning "Failed to install Zed"

# Browsers & Communication
print_step "Installing browsers and communication apps..."
yay -S --noconfirm vivaldi || print_warning "Failed to install Vivaldi"
yay -S --noconfirm discord || print_warning "Failed to install Discord"
yay -S --noconfirm zoom || print_warning "Failed to install Zoom"

# Productivity & Utilities
print_step "Installing productivity apps..."
yay -S --noconfirm 1password || print_warning "Failed to install 1Password"
yay -S --noconfirm obsidian || print_warning "Failed to install Obsidian"
yay -S --noconfirm localsend-bin || print_warning "Failed to install LocalSend"
yay -S --noconfirm pinta || print_warning "Failed to install Pinta"

# Gaming
print_step "Installing gaming platforms..."
yay -S --noconfirm steam || print_warning "Failed to install Steam"

# Optional: Docker Desktop (comment out if you prefer CLI-only Docker)
# yay -S --noconfirm docker-desktop || print_warning "Failed to install Docker Desktop"

# Enable and start essential services
print_step "Configuring system services..."
sudo systemctl enable --now pipewire pipewire-pulse wireplumber
sudo systemctl enable --now docker || print_warning "Docker not installed via pacman, using Nix version"

# Set up Hyprland session
print_step "Setting up Hyprland desktop session..."
sudo pacman -S --noconfirm hyprland xdg-desktop-portal-hyprland xdg-desktop-portal-gtk

# Install display manager if not present
if ! systemctl is-active --quiet sddm && ! systemctl is-active --quiet gdm && ! systemctl is-active --quiet lightdm; then
    print_step "Installing SDDM display manager..."
    sudo pacman -S --noconfirm sddm
    sudo systemctl enable sddm
    print_success "SDDM display manager installed and enabled"
fi

# Create some useful directories
mkdir -p ~/Code ~/Documents/Screenshots

echo ""
print_success "🎉 Arch + Nix + Hyprland setup complete!"
echo ""
echo "🌟 What you now have:"
echo "   • Hyprland tiling window manager (like omarchy)"
echo "   • All your CLI tools managed by Nix"
echo "   • Development apps from AUR"
echo "   • Coordinated theming and configs"
echo ""
echo "📋 Next steps:"
echo "   1. Reboot your system: sudo reboot"
echo "   2. At login, select 'Hyprland' as your session"
echo "   3. Use Super+Enter for terminal (ghostty)"
echo "   4. Use Super+R for application launcher (wofi)"
echo "   5. To update configs: edit ~/.setup/arch/flake.nix and run 'rebuild'"
echo ""
echo "⌨️  Key bindings (like omarchy):"
echo "   • Super+Enter: Terminal"
echo "   • Super+R: App launcher" 
echo "   • Super+Q: Close window"
echo "   • Super+1-6: Switch workspaces"
echo "   • Super+Shift+1-6: Move window to workspace"
echo "   • Print: Screenshot region"
echo ""
echo "🚀 Welcome to your new Arch Linux development environment!"
echo "   Inspired by omarchy, powered by Nix, tailored for you!"