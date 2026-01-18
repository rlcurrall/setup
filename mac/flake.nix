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
      me = "robb";
      home = "/Users/${me}";
      configuration = { lib, pkgs, ... }: {
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
          pkgs.atuin
          pkgs.fd
          pkgs.zellij
          pkgs.starship
          pkgs.mise
          pkgs.zoxide

          pkgs.uv
          pkgs.zig
          pkgs.rustup
          pkgs.just

          pkgs.mas
          pkgs.btop
          pkgs.vim
          pkgs.neovim
          pkgs.lazygit
          pkgs.lazydocker
          pkgs.docker
          pkgs.ffmpeg

          pkgs.tailscale
          pkgs.llama-cpp
          pkgs.ollama
        ];

        homebrew = {
          enable = true;
          taps = [ "azure/functions" "sst/tap" ];
          brews = [
            "azure-functions-core-tools@4"
            "gemini-cli"
            "gh"
            "pulumi"
            "sst/tap/opencode"
            "coreutils"
          ];
          casks = [
            "1password"
            "1password-cli"
            "bruno"
            "claude"
            "claude-code"
            "cursor"
            "discord"
            "displaperture"
            "docker-desktop"
            "dotnet-sdk"
            "ghostty"
            "hyperkey"
            "localsend"
            "minecraft"
            "obs"
            "pinta"
            "powershell"
            "raycast"
            "rider"
            "spotify"
            "steam"
            "tableplus"
            "visual-studio-code"
            "vivaldi"
            "zed"
            "zoom"
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
            { app = "/Applications/1Password.app"; }
            { app = "/Applications/Claude.app"; }

            # Development
            { app = "/Applications/TablePlus.app"; }
            { app = "/Applications/Bruno.app"; }
            { app = "/Applications/Docker.app"; }

            # Communication & Media
            { app = "/Applications/Discord.app"; }
            { app = "/Applications/zoom.us.app"; }
            { app = "/Applications/Vivaldi.app"; }

            # Utilities
            { app = "/Applications/Pinta.app"; }
            { app = "/Applications/OBS.app"; }
            { app = "/Applications/LocalSend.app"; }
          ];
          finder.AppleShowAllExtensions = true;
          finder.FXPreferredViewStyle = "clmv";
          screencapture.location = "~/Pictures/screenshots";
          screensaver.askForPasswordDelay = 10;
        };

        # Enable Tailscale
        services.tailscale.enable = true;

        users.users.${me} = {
          name = me;
          home = home;
        };
      };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#simple
      darwinConfigurations."helheim" = nix-darwin.lib.darwinSystem {
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
                  rebuild = "(cd ~/.setup/mac && darwin-rebuild switch --flake .#helheim)";
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

                  # Load environment variables
                  . ~/.vars

                  # Docker Desktop completions
                  fpath=(/Users/robb/.docker/completions $fpath)
                  autoload -Uz compinit
                  compinit

                  # Initialize starship
                  eval "$(starship init zsh)"
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
