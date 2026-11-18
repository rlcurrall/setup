{ me, home, ... }:
{
  imports = [ ./files.nix ./environment.nix ./shell.nix ./services.nix ./tools.nix ];

  # Home Manager needs a bit of information about you and the paths it should manage
  home.username = me;
  home.homeDirectory = home;
  home.stateVersion = "24.05";

  # Disable version mismatch warning
  home.enableNixpkgsReleaseCheck = false;

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Robb Currall";
        email = "rlcurrall@gmail.com";
      };
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
    };
  };

  programs.home-manager.enable = true;
}
