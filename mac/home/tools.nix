{ config, pkgs, ... }:
{
  # Auto-install mise tools during home-manager activation
  home.activation.miseInstall = config.lib.dag.entryAfter [ "linkGeneration" ] ''
    # Mise's installers need curl and macOS utilities (getconf, awk, tar).
    export PATH="${pkgs.mise}/bin:${pkgs.curl}/bin:$PATH:/usr/bin:/bin:/usr/sbin:/sbin"
    $DRY_RUN_CMD ${pkgs.mise}/bin/mise install
  '';
}
