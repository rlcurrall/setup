{ config, lib, me, ... }:
{
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      upgrade = false;
      cleanup = "none";
    };
    taps = [ "hashicorp/tap" "microsoft/aspire" "anomalyco/tap" ];
    brews = [
      "anomalyco/tap/opencode-v2"
      "coreutils"
      "gh"
      "hashicorp/tap/terraform"
      "hashicorp/tap/vault"
      "herdr"
      "libpq"
      "pi-coding-agent"
      # Its Brew-managed dotnet dependency is separate from Mise's dev SDKs.
      "powershell"
      "pulumi"
      "sqlcmd"
      "tailscale"
    ];
    casks = [
      "1password"
      "1password-cli"
      "anomalyco/tap/hex"
      "antigravity-cli"
      "microsoft/aspire/aspire"
      "claude"
      "claude-code"
      "codex"
      "docker-desktop"
      "ghostty"
      "helium-browser"
      "hyperkey"
      "localsend"
      "pinta"
      "raycast"
      "spotify"
      "tableplus"
      "tailscale-app"
      "typora"
      "visual-studio-code"
      "vivaldi"
    ];
  };

  # Auto-trust third-party taps as the primary user before Homebrew Bundle
  # tries to install formulae from them. System activation runs as root.
  system.activationScripts.preActivation.text = lib.mkAfter ''
    if [ -x /opt/homebrew/bin/brew ]; then
      for tap in ${lib.concatStringsSep " " (map (t: t.name) config.homebrew.taps)}; do
        /usr/bin/sudo -H -u ${me} /opt/homebrew/bin/brew trust --tap "$tap"
      done
    fi
  '';
}
