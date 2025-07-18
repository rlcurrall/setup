{
  description = "Home Manager configuration for Ubuntu";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }: {
    homeConfigurations.robb = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [ ./home.nix ];
    };

    # Installation script as a Nix app
    apps.x86_64-linux.install = {
      type = "app";
      program = "${nixpkgs.legacyPackages.x86_64-linux.writeShellScript "install" ''
        set -e

        printf "\n🚀 Setting up your Ubuntu machine with Nix + Home Manager...\n\n"

        # Install essential system dependencies
        printf "📦 Installing system dependencies...\n"
        sudo apt update -y
        sudo apt install -y curl git xz-utils ca-certificates snapd flatpak gnome-software-plugin-flatpak

        # Install Nix if not already installed
        if [ ! -d "/nix" ]; then
            printf "🔧 Installing Nix package manager...\n"
            curl -L https://nixos.org/nix/install | sh
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

        # Configure Nix with flakes
        printf "🔧 Configuring Nix with flakes support...\n"
        mkdir -p ~/.config/nix
        echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf
        printf "✅ Flakes enabled\n"

        # Apply Home Manager configuration
        printf "🏠 Applying Home Manager configuration...\n"
        cd ~/.setup/linux
        nix run home-manager/master -- switch --flake .#robb
        printf "✅ Home Manager configuration applied successfully!\n"

        # Install GUI applications that can't be handled by Nix
        printf "🖥️  Installing essential GUI applications...\n"

        # Setup Flatpak
        sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

        # Install via snap (better desktop integration)
        sudo snap install ghostty --classic || printf "⚠️  Failed to install Ghostty via snap\n"
        sudo snap install discord --classic || printf "⚠️  Failed to install Discord via snap\n"
        sudo snap install code --classic || printf "⚠️  Failed to install VS Code via snap\n"

        # Install via flatpak
        flatpak install -y flathub com.vivaldi.Vivaldi || printf "⚠️  Failed to install Vivaldi via flatpak\n"
        flatpak install -y flathub org.localsend.localsend_app || printf "⚠️  Failed to install LocalSend via flatpak\n"

        printf "\n🎉 Setup complete!\n\n"
        printf "Next steps:\n"
        printf "1. Restart your shell or run: source ~/.nix-profile/etc/profile.d/nix.sh\n"
        printf "2. Your development tools are now managed by Home Manager\n"
        printf "3. To update your configuration: edit ~/.setup/linux/home.nix and run 'rebuild'\n"
        printf "4. Install any additional GUI apps you need via apt/snap/flatpak\n\n"
        printf "Happy coding! 🚀\n"
      ''}";
    };
  };
}

