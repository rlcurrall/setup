{ config, lib, ... }:
{
  homebrew.casks = [ "discord" "minecraft" "obs" "steam" ];

  home-manager.users.${config.system.primaryUser}.programs.zsh.initContent = lib.mkOrder 780 ''
    # Populate Homebrew's completion directories before Oh My Zsh initializes.
    eval "$(/opt/homebrew/bin/brew shellenv)"
  '';
}
