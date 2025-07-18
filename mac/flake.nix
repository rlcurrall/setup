{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
    let
      me = builtins.getEnv "USER";
      home = "/Users/${me}";
      configuration = { lib, pkgs, ... }: {
        # Configure unfree packages
        nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ ];

        fonts.packages = [ pkgs.fira-code pkgs.fira-code-symbols ];

        # List packages installed in system profile. To search by name, run:
        # $ nix-env -qaP | grep wget
        environment.systemPackages = [
          pkgs.zsh
          pkgs.fish
          pkgs.git
          pkgs.jq
          pkgs.ripgrep
          pkgs.fzf
          pkgs.bat
          pkgs.atuin
          pkgs.fd
          pkgs.zellij

          pkgs.uv
          pkgs.go
          pkgs.zig
          pkgs.bun
          pkgs.deno
          pkgs.rustup
          pkgs.just

          pkgs.mas
          pkgs.btop
          pkgs.vim
          pkgs.neovim
          pkgs.lazygit
          pkgs.docker
          pkgs.colima
          pkgs.ffmpeg

          pkgs.tailscale
          pkgs.localsend
          pkgs.llama-cpp
          pkgs.ollama
        ];

        homebrew = {
          enable = true;
          taps = [ "azure/functions" ];
          brews = [
            "azure-functions-core-tools@4"
            "gh"
            "nvm"
            "pulumi"
          ];
          casks = [
            "1password"
            "1password-cli"
            "bruno"
            "claude"
            "discord"
            "docker"
            "dotnet-sdk"
            "ghostty"
            "hyperkey"
            "pinta"
            "minecraft"
            "msty"
            "raycast"
            "rider"
            "tableplus"
            "visual-studio-code"
            "vivaldi"
            "zoom"
            "cursor"
            "zed"
          ];
          masApps = {
            Magnet = 441258766;
          };
        };

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
        environment.shells = [ pkgs.fish pkgs.zsh ];

        # Set Git commit hash for darwin-version.
        system.configurationRevision = self.rev or self.dirtyRev or null;

        # Used for backwards compatibility, please read the changelog before changing.
        # $ darwin-rebuild changelog
        system.stateVersion = 6;

        # The platform the configuration will be used on.
        nixpkgs.hostPlatform = "aarch64-darwin";

        # GUI defaults
        system.defaults = {
          dock.autohide = true;
          dock.mru-spaces = false;
          dock.show-recents = false;
          dock.persistent-apps = [
            { app = "/Applications/Ghostty.app"; }
            { app = "/Applications/1Password.app"; }
            { app = "/Applications/Discord.app"; }
            { app = "/Applications/TablePlus.app"; }
            { app = "/Applications/Vivaldi.app"; }
            { app = "/Applications/Pinta.app"; }
            { app = "/Applications/Bruno.app"; }
            { app = "/Applications/Nix Apps/LocalSend.app"; }
          ];
          finder.AppleShowAllExtensions = true;
          finder.FXPreferredViewStyle = "clmv";
          screencapture.location = "~/Pictures/screenshots";
          screensaver.askForPasswordDelay = 10;
        };

        # Enable Tailscale
        services.tailscale.enable = true;
      };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#simple
      darwinConfigurations."helheim" = nix-darwin.lib.darwinSystem {
        modules = [ configuration ];
      };
    };
}
