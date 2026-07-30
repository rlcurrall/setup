{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager }:
    let
      me = "robcurrall";
      home = "/Users/${me}";
      hostname = "helheim";
      configuration = { lib, pkgs, config, ... }: {
        # Configure unfree packages
        nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ ];

        fonts.packages = [
          pkgs.fira-code
          pkgs.fira-code-symbols
          pkgs.nerd-fonts.fira-code
          pkgs.nerd-fonts.jetbrains-mono
          pkgs.nerd-fonts.hack
        ];

        # List packages installed in system profile. To search by name, run:
        # $ nix-env -qaP | grep wget
        environment.systemPackages = [
          pkgs.zsh
          pkgs.git
          pkgs.jq
          pkgs.ripgrep
          pkgs.fzf
          pkgs.bat
          pkgs.fd
          pkgs.zellij
          pkgs.mise

          pkgs.uv
          pkgs.zig
          pkgs.rustup
          pkgs.just

          pkgs.btop
          pkgs.vim
          pkgs.neovim
          pkgs.lazygit
          pkgs.lazydocker
          pkgs.ffmpeg

          pkgs.llama-cpp
          pkgs.ollama
        ];

        homebrew = {
          enable = true;
          taps = [ "azure/functions" "hashicorp/tap" "sst/tap" ];
          brews = [
            "azure-cli"
            "azure-dev"
            "azure-functions-core-tools@4"
            "beads"
            "coreutils"
            "dotnet"
            "gh"
            "hashicorp/tap/terraform"
            "ollama"
            "pi-coding-agent"
            "powershell"
            "pulumi"
            "sst/tap/opencode"
          ];
          casks = [
            "1password"
            "1password-cli"
            "antigravity-cli"
            "claude"
            "claude-code"
            "codex"
            "discord"
            "docker-desktop"
            "ghostty"
            "helium-browser"
            "hyperkey"
            "kitlangton-hex"
            "localsend"
            "minecraft"
            "ollama-app"
            "pinta"
            "raycast"
            "spotify"
            "steam"
            "tableplus"
            "tailscale-app"
            "visual-studio-code"
            "vivaldi"
          ];
        };

        # Auto-trust third-party taps as the invoking user before Homebrew Bundle
        # tries to install formulae from them.
        system.activationScripts.preUserActivation.text = lib.mkAfter ''
          if [ -x /opt/homebrew/bin/brew ]; then
            for tap in ${lib.concatStringsSep " " (map (t: t.name) config.homebrew.taps)}; do
              /opt/homebrew/bin/brew trust --tap "$tap"
            done
          fi
        '';

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
        system.configurationRevision = self.rev or self.dirtyRev or null;

        # Used for backwards compatibility, please read the changelog before changing.
        # $ darwin-rebuild changelog
        system.stateVersion = 6;

        # The platform the configuration will be used on.
        nixpkgs.hostPlatform = "aarch64-darwin";

        # GUI defaults
        system.defaults = {
          # Reduce/disable animations
          NSGlobalDomain.NSWindowResizeTime = 0.001;

          dock.autohide = true;
          dock.autohide-delay = 0.0;
          dock.autohide-time-modifier = 0.0;
          dock.launchanim = false;
          dock.mineffect = "scale";
          dock.expose-animation-duration = 0.12;
          dock.mru-spaces = false;
          dock.show-recents = false;
          dock.persistent-apps = [
            # Core productivity
            { app = "/Applications/Ghostty.app"; }

            # Development
            { app = "/Applications/TablePlus.app"; }

            # Communication & Media
            { app = "/Applications/Discord.app"; }
            { app = "/Applications/Vivaldi.app"; }
          ];
          finder.AppleShowAllExtensions = true;
          finder.FXPreferredViewStyle = "clmv";
          screencapture.location = "~/Pictures/screenshots";
          screensaver.askForPasswordDelay = 10;
        };

        users.users.${me} = {
          name = me;
          home = home;
        };
      };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#simple
      darwinConfigurations.${hostname} = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.users.${me} = { config, pkgs, ... }: {
              # Home Manager needs a bit of information about you and the paths it should manage
              home.username = me;
              home.homeDirectory = home;
              home.stateVersion = "24.05";

              # Disable version mismatch warning
              home.enableNixpkgsReleaseCheck = false;

              # Shell configuration now managed by programs.zsh
              home.file = {
                # Create Code directory
                "Code/.keep".text = "";
              };

              xdg.configFile = {
                "nvim" = {
                  source = ../config/nvim;
                  recursive = true;
                };

                "btop" = {
                  source = ../config/btop;
                  recursive = true;
                };

                "lazygit" = {
                  source = ../config/lazygit;
                  recursive = true;
                };

                "ghostty" = {
                  source = ../config/ghostty;
                  recursive = true;
                };

                "mise" = {
                  source = ../config/mise;
                  recursive = true;
                };

                "zellij" = {
                  source = ../config/zellij;
                  recursive = true;
                };
                "starship.toml" = {
                  source = ../config/starship.toml;
                };
              };

              home.sessionVariables = {
                EDITOR = "nvim";
                BROWSER = "vivaldi";
                TERMINAL = "ghostty";
              };

              # ===== PROGRAMS =====
              programs.zsh = {
                enable = true;
                enableCompletion = true;
                autosuggestion.enable = true;
                syntaxHighlighting.enable = true;

                oh-my-zsh = {
                  enable = true;
                  plugins = [ "git" ];
                };

                shellAliases = {
                  rebuild = "(cd ~/.setup/mac && darwin-rebuild switch --flake .#${hostname})";
                  lg = "lazygit";
                };

                initContent = ''
                  # Add Homebrew to PATH
                  eval "$(/opt/homebrew/bin/brew shellenv)"

                  # Mise activation
                  eval "$(mise activate zsh)"

                  # Add .NET Core SDK tools
                  export PATH="$PATH:$HOME/.dotnet/tools"

                  # Add custom bin to path
                  export PATH="$HOME/.bin:$PATH"

                  # Add local bin to path
                  export PATH="$HOME/.local/bin:$PATH"

                  # Load environment variables (if present)
                  [ -f ~/.vars ] && . ~/.vars

                  # Docker Desktop completions
                  fpath=(${home}/.docker/completions $fpath)
                  autoload -Uz compinit
                  compinit

                '';
              };

              programs.starship = {
                enable = true;
                enableZshIntegration = true;
              };

              programs.atuin = {
                enable = true;
                enableZshIntegration = true;
                settings = {
                  enter_accept = true;
                  sync.records = true;
                };
              };

              programs.git = {
                enable = true;
                userName = "Robb Currall";
                userEmail = "rlcurrall@gmail.com";
                extraConfig = {
                  init.defaultBranch = "main";
                  push.autoSetupRemote = true;
                };
              };

              programs.zoxide = {
                enable = true;
                enableZshIntegration = true;
              };

              # Auto-install mise tools during home-manager activation
              home.activation.miseInstall = config.lib.dag.entryAfter [ "writeBoundary" ] ''
                export PATH="${pkgs.mise}/bin:$PATH"
                $DRY_RUN_CMD ${pkgs.mise}/bin/mise install
              '';

              # Let Home Manager install and manage itself
              programs.home-manager.enable = true;
            };
          }
        ];
      };
    };
}
