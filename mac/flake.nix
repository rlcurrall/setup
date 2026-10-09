{
  description = "Personal and work macOS configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager }:
    let
      mkMachine = { me, profile }: let
      home = "/Users/${me}";
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
          taps = [ "azure/functions" "hashicorp/tap" "sst/tap" "databricks/tap" "microsoft/aspire" ];
          brews = [
            "azure-cli"
            "azure-dev"
            "azure-functions-core-tools@4"
            "beads"
            "coreutils"
            "databricks"
            "dotnet"
            "dotnet@8"
            "gh"
            "glab"
            "hashicorp/tap/terraform"
            "hashicorp/tap/vault"
            "herdr"
            "libpq"
            "ollama"
            "pi-coding-agent"
            "powershell"
            "pulumi"
            "pup"
            "sqlcmd"
            "sst/tap/opencode"
            "tailscale"
          ];
          casks = [
            "1password"
            "1password-cli"
            "android-commandlinetools"
            "android-studio"
            "antigravity-cli"
            "microsoft/aspire/aspire"
            "chatgpt"
            "claude"
            "claude-code"
            "codex"
            "discord"
            "docker-desktop"
            "dotnet-sdk"
            "ghostty"
            "granola"
            "helium-browser"
            "hyperkey"
            "localsend"
            "minecraft"
            "obs"
            "ollama-app"
            "pinta"
            "raycast"
            "spotify"
            "steam"
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

        # Options such as Homebrew and macOS defaults apply to this user.
        system.primaryUser = me;

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
            { app = "/Applications/Ghostty.app"; }
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
      nix-darwin.lib.darwinSystem {
        modules = [
          configuration
          (./profiles + "/${profile}.nix")
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
                ANDROID_HOME = "${home}/Library/Android/sdk";
                ANDROID_SDK_ROOT = "${home}/Library/Android/sdk";
                EDITOR = "nvim";
                BROWSER = "vivaldi";
                JAVA_HOME = "/Applications/Android Studio.app/Contents/jbr/Contents/Home";
                TERMINAL = "ghostty";
              };

              # Keep Claude Remote Control available for sessions started from
              # claude.ai/code or the Claude mobile app.
              launchd.agents.claude-remote-control = {
                enable = true;
                config = {
                  ProgramArguments = [
                    "/opt/homebrew/bin/claude"
                    "remote-control"
                  ];
                  WorkingDirectory = "${home}/Code";
                  EnvironmentVariables = {
                    HOME = home;
                    PATH = "/opt/homebrew/bin:/opt/homebrew/sbin:${home}/.local/bin:${home}/.bin:/etc/profiles/per-user/${me}/bin:/run/current-system/sw/bin:/usr/bin:/bin:/usr/sbin:/sbin";
                  };
                  RunAtLoad = true;
                  KeepAlive = true;
                  ThrottleInterval = 10;
                  ProcessType = "Background";
                  StandardOutPath = "${home}/Library/Logs/claude-remote-control.log";
                  StandardErrorPath = "${home}/Library/Logs/claude-remote-control.error.log";
                };
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
                  rebuild = "(cd ~/.setup/mac && sudo /run/current-system/sw/bin/darwin-rebuild switch --flake .#${profile})";
                  lg = "lazygit";
                };

                initContent = ''
                  # Add Homebrew to PATH
                  eval "$(/opt/homebrew/bin/brew shellenv)"

                  # Mise activation
                  eval "$(mise activate zsh)"

                  # Add .NET Core SDK tools
                  export PATH="$PATH:$HOME/.dotnet/tools"

                  # Add Postgres CLI
                  export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

                  # Android SDK tools
                  export PATH="$ANDROID_HOME/platform-tools:$PATH"

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
                settings = {
                  user = {
                    name = "Robb Currall";
                    email = "rlcurrall@gmail.com";
                  };
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
    in {
      darwinConfigurations = {
        personal = mkMachine { me = "robb"; profile = "personal"; };
        work = mkMachine { me = "robcurrall"; profile = "work"; };
        # Compatibility with the existing personal-machine rebuild alias.
        helheim = self.darwinConfigurations.personal;
      };
    };
}
