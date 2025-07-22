{
  description = "Home Manager configuration for Robb on Ubuntu";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flatpak-nix.url = "github:gmodena/flatpak-nix";
  };

  outputs = { nixpkgs, home-manager, flatpak-nix, ... }: {
    homeConfigurations.robb = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [
        # Import our modular configuration files
        ./home.nix
        ./gnome.nix
        ./apps.nix

        # Enable declarative flatpak support
        flatpak-nix.homeManagerModules.flatpak
      ];
    };
  };
}

