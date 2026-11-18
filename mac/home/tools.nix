{ config, pkgs, ... }:
{
  # Auto-install mise tools during home-manager activation
  home.activation.miseInstall = config.lib.dag.entryAfter [ "linkGeneration" ] ''
    export PATH="${pkgs.mise}/bin:$PATH"
    $DRY_RUN_CMD ${pkgs.mise}/bin/mise install
  '';
}
