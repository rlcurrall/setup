{ lib, pkgs, me, home, revision, ... }:
{
  nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ ];

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

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
