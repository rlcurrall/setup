{
  description = "Personal and work macOS configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nix-darwin, home-manager, ... }:
    let
      mkMachine = { me, profile }:
        let
          home = "/Users/${me}";
        in
        nix-darwin.lib.darwinSystem {
          specialArgs = {
            inherit me home;
            revision = self.rev or self.dirtyRev or null;
          };
          modules = [
            ./modules/system.nix
            ./modules/packages.nix
            ./modules/homebrew.nix
            ./modules/defaults.nix
            (./profiles + "/${profile}.nix")
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.extraSpecialArgs = { inherit me home profile; };
              home-manager.users.${me} = import ./home;
            }
          ];
        };
    in
    {
      checks.aarch64-darwin = {
        personal = self.darwinConfigurations.personal.system;
        work = self.darwinConfigurations.work.system;
      };

      darwinConfigurations = {
        personal = mkMachine { me = "robb"; profile = "personal"; };
        work = mkMachine { me = "robcurrall"; profile = "work"; };
        # Compatibility with the existing personal-machine rebuild alias.
        helheim = self.darwinConfigurations.personal;
      };
    };
}
