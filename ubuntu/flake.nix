{
  description = "Home Manager configuration for Robb on Ubuntu";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-flatpak.url = "github:gmodena/nix-flatpak";
    ghostty = {
      url = "github:ghostty-org/ghostty";
    };
  };

  outputs = { nixpkgs, home-manager, nix-flatpak, ghostty, ... }: {
    homeConfigurations.robb = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [
        # Import our modular configuration files
        ./home.nix
        ./gnome.nix
        ./apps.nix

        # Enable declarative flatpak support
        nix-flatpak.homeManagerModules.nix-flatpak

        # Make Ghostty available to all modules
        {
          _module.args.ghostty = ghostty;
        }
      ];
    };
  };
}

