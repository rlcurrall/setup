{ config, lib, me, ... }:
{
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      upgrade = false;
      cleanup = "none";
    };
    taps = [ "azure/functions" "hashicorp/tap" "databricks/tap" "microsoft/aspire" "anomalyco/tap" ];
    brews = [
      "azure-cli"
      "azure-dev"
      "azure-functions-core-tools@4"
      "anomalyco/tap/opencode-v2"
      "beads"
      "coreutils"
      "databricks"
      "gh"
      "glab"
      "hashicorp/tap/terraform"
      "hashicorp/tap/vault"
      "herdr"
      "libpq"
      "pi-coding-agent"
      # Its Brew-managed dotnet dependency is separate from Mise's dev SDKs.
      "powershell"
      "pulumi"
      "pup"
      "sqlcmd"
      "tailscale"
    ];
    casks = [
      "1password"
      "1password-cli"
      "android-commandlinetools"
      "android-studio"
      "anomalyco/tap/hex"
      "antigravity-cli"
      "microsoft/aspire/aspire"
      "chatgpt"
      "claude"
      "claude-code"
      "codex"
      "docker-desktop"
      "ghostty"
      "granola"
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
