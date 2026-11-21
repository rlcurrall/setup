{ lib, pkgs, me, home, revision, ... }:
{
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ ];

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  # The Lix installer bootstraps new machines; nix-darwin manages upstream Nix.
  nix.package = pkgs.nix;

  # Retain recent rollback generations; collect unused store paths weekly.
  nix.gc = {
    automatic = true;
    options = "--delete-older-than 30d";
    interval = [{ Weekday = 7; Hour = 3; Minute = 15; }];
  };

  # Enable touch ID for sudo
  security.pam.services.sudo_local.touchIdAuth = true;

  # Enable alternative shell support in nix-darwin.
  programs.zsh = {
    enable = true;
    enableFzfCompletion = true;
    enableFzfGit = true;
    enableFzfHistory = true;
  };

  # Set available shells
  environment.shells = [ pkgs.zsh ];

  # Set Git commit hash for darwin-version.
  system.configurationRevision = revision;

  # Options such as Homebrew and macOS defaults apply to this user.
  system.primaryUser = me;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";

  users.users.${me} = {
    name = me;
    home = home;
  };
}
