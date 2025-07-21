{
  description = "Home Manager configuration for Arch Linux + Omarchy inspiration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }: {
    homeConfigurations.robb = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [
        ({ config, pkgs, ... }: {
          # Home Manager needs a bit of information about you and the paths it should manage
          home.username = "robb";
          home.homeDirectory = "/home/robb";
          home.stateVersion = "24.05";

          # Allow unfree packages
          nixpkgs.config.allowUnfree = true;

          # Disable version mismatch warning
          home.enableNixpkgsReleaseCheck = false;

          # Enable generic Linux targets for better integration
          targets.genericLinux.enable = true;

          # Packages installed in user profile
          home.packages = with pkgs; [
            # ===== CLI TOOLS =====
            zsh
            git
            jq
            ripgrep
            fzf
            bat
            atuin
            fd
            zellij
            starship
            mise
            zoxide

            # Enhanced CLI tools (omarchy-inspired)
            eza # Modern ls replacement with icons
            fastfetch # System info (neofetch replacement)
            tldr # Simplified man pages
            tree-sitter # Syntax highlighting
            luarocks # Lua package manager for neovim

            # ===== DEVELOPMENT TOOLS =====
            uv
            zig
            rustup
            just
            btop
            vim
            neovim
            lazygit
            lazydocker
            ffmpeg
            docker
            docker-compose
            tailscale
            github-cli # gh command

            # ===== AI/ML TOOLS =====
            llama-cpp
            ollama

            # ===== FONTS (OMARCHY STYLE) =====
            fira-code
            fira-code-symbols
            nerd-fonts.fira-code
            nerd-fonts.jetbrains-mono
            nerd-fonts.hack
            nerd-fonts.caskaydia-cove # CaskaydiaMono from omarchy
            font-awesome # Icon fonts
            noto-fonts # Unicode coverage
            noto-fonts-cjk # Asian language support
            noto-fonts-emoji # Emoji support

            # ===== HYPRLAND DESKTOP (OMARCHY CORE) =====
            hyprland
            hyprshot # Screenshot tool
            hyprpicker # Color picker
            hyprlock # Screen locker
            hypridle # Idle management
            hyprpaper # Wallpaper manager

            # Desktop components
            wofi # Application launcher (omarchy's dmenu)
            waybar # Status bar
            mako # Notification daemon
            polkit-gnome # Authentication agent

            # ===== WAYLAND UTILITIES =====
            wl-clipboard # Clipboard utilities
            brightnessctl # Screen brightness
            playerctl # Media player control
            pamixer # Audio mixer
            grim # Screenshot utility
            slurp # Screen selection for screenshots
            xdg-desktop-portal-hyprland
            xdg-desktop-portal-gtk

            # ===== GUI APPLICATIONS =====
            # Terminal & Core Apps
            alacritty # Terminal (omarchy default)
            chromium # Browser (omarchy default)

            # Your preferred apps
            ghostty # Your preferred terminal
            obs-studio # Screen recording/streaming
            prismlauncher # Minecraft launcher

            # Development GUI
            # Note: VS Code, Cursor, Zed, etc. better via AUR for full functionality

            # Media & Graphics
            mpv # Media player (omarchy default)
            imv # Image viewer

            # Media Production Tools
            kdenlive # Video editing
            audacity # Audio editing
            gimp # Advanced image editing
            blender # 3D modeling and video editing

            # File management
            nautilus # File manager
            sushi # Nautilus previews

            # ===== AUDIO & MEDIA =====
            wireplumber # Audio session manager
            pavucontrol # Audio control GUI
            ffmpegthumbnailer # Video thumbnails

            # ===== SYSTEM UTILITIES =====
            imagemagick # Image manipulation
            unzip
            wget
            curl

            # Development libraries
            gcc
            clang
            llvm
          ];

          # Create Code directory
          home.file."Code/.keep".text = "";

          # ===== DOTFILES MANAGEMENT =====
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

            # Hyprland configuration
            "hypr/hyprland.conf" = {
              text = ''
                # Hyprland configuration
                # Based on omarchy setup but customized for your workflow

                # Monitor setup
                monitor=,preferred,auto,auto

                # Input configuration
                input {
                    kb_layout = us
                    follow_mouse = 1
                    touchpad {
                        natural_scroll = no
                    }
                    sensitivity = 0
                }

                # General configuration - Tokyo Night Storm colors
                general {
                    gaps_in = 5
                    gaps_out = 20
                    border_size = 2
                    col.active_border = rgba(7aa2f7ee) rgba(bb9af7ee) 45deg  # Tokyo Night blue/purple gradient
                    col.inactive_border = rgba(565f89aa)  # Tokyo Night muted
                    layout = dwindle
                }

                # Decoration
                decoration {
                    rounding = 10
                    blur {
                        enabled = true
                        size = 3
                        passes = 1
                    }
                    drop_shadow = yes
                    shadow_range = 4
                    shadow_render_power = 3
                    col.shadow = rgba(1a1a1aee)
                }

                # Animations
                animations {
                    enabled = yes
                    bezier = myBezier, 0.05, 0.9, 0.1, 1.05
                    animation = windows, 1, 7, myBezier
                    animation = windowsOut, 1, 7, default, popin 80%
                    animation = border, 1, 10, default
                    animation = borderangle, 1, 8, default
                    animation = fade, 1, 7, default
                    animation = workspaces, 1, 6, default
                }

                # Layout
                dwindle {
                    pseudotile = yes
                    preserve_split = yes
                }

                # Key bindings (similar to omarchy)
                $mainMod = SUPER

                # Applications
                bind = $mainMod, RETURN, exec, ghostty
                bind = $mainMod, Q, killactive,
                bind = $mainMod, M, exit,
                bind = $mainMod, E, exec, nautilus
                bind = $mainMod, V, togglefloating,
                bind = $mainMod, R, exec, wofi --show drun
                bind = $mainMod, P, pseudo,
                bind = $mainMod, J, togglesplit,

                # Screenshot
                bind = , Print, exec, hyprshot -m region
                bind = $mainMod, Print, exec, hyprshot -m output

                # Move focus
                bind = $mainMod, left, movefocus, l
                bind = $mainMod, right, movefocus, r
                bind = $mainMod, up, movefocus, u
                bind = $mainMod, down, movefocus, d

                # Switch workspaces
                bind = $mainMod, 1, workspace, 1
                bind = $mainMod, 2, workspace, 2
                bind = $mainMod, 3, workspace, 3
                bind = $mainMod, 4, workspace, 4
                bind = $mainMod, 5, workspace, 5
                bind = $mainMod, 6, workspace, 6

                # Move window to workspace
                bind = $mainMod SHIFT, 1, movetoworkspace, 1
                bind = $mainMod SHIFT, 2, movetoworkspace, 2
                bind = $mainMod SHIFT, 3, movetoworkspace, 3
                bind = $mainMod SHIFT, 4, movetoworkspace, 4
                bind = $mainMod SHIFT, 5, movetoworkspace, 5
                bind = $mainMod SHIFT, 6, movetoworkspace, 6

                # Auto-start applications
                exec-once = waybar
                exec-once = mako
                exec-once = hyprpaper
                exec-once = /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
              '';
            };

            # Waybar configuration (status bar) - Tokyo Night Storm theme
            "waybar/config" = {
              text = builtins.toJSON {
                layer = "top";
                position = "top";
                height = 35;
                spacing = 8;
                modules-left = [ "hyprland/workspaces" "hyprland/mode" ];
                modules-center = [ "hyprland/window" ];
                modules-right = [ "pulseaudio" "network" "cpu" "memory" "battery" "clock" "tray" ];

                "hyprland/workspaces" = {
                  disable-scroll = true;
                  all-outputs = true;
                  format = "{icon}";
                  format-icons = {
                    "1" = "󰲠";
                    "2" = "󰲢";
                    "3" = "󰲤";
                    "4" = "󰲦";
                    "5" = "󰲨";
                    "6" = "󰲪";
                    "default" = "";
                  };
                  persistent-workspaces = {
                    "*" = 6;
                  };
                };

                "hyprland/window" = {
                  format = "{}";
                  max-length = 50;
                  separate-outputs = true;
                };

                network = {
                  format-wifi = "󰤨 {essid} ({signalStrength}%)";
                  format-ethernet = "󰈀 Connected";
                  format-disconnected = "󰤭 Disconnected";
                  tooltip-format = "{ifname} via {gwaddr}";
                  tooltip-format-wifi = "{essid} ({signalStrength}%)";
                  on-click = "nm-connection-editor";
                };

                pulseaudio = {
                  format = "{icon} {volume}%";
                  format-bluetooth = "{icon} {volume}%";
                  format-muted = "󰖁";
                  format-icons = {
                    headphone = "";
                    hands-free = "";
                    headset = "";
                    phone = "";
                    portable = "";
                    car = "";
                    default = [ "" "" "" ];
                  };
                  on-click = "pavucontrol";
                  scroll-step = 5;
                };

                cpu = {
                  format = " {usage}%";
                  tooltip = false;
                  interval = 2;
                };

                memory = {
                  format = " {percentage}%";
                  tooltip-format = "Used: {used:0.1f}G / {total:0.1f}G";
                  interval = 10;
                };

                battery = {
                  states = {
                    warning = 30;
                    critical = 15;
                  };
                  format = "{icon} {capacity}%";
                  format-charging = "󰂄 {capacity}%";
                  format-plugged = "󰂄 {capacity}%";
                  format-alt = "{icon} {time}";
                  format-icons = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
                  tooltip-format = "{timeTo}";
                };

                clock = {
                  format = "󰥔 {:%H:%M}";
                  format-alt = "󰃭 {:%Y-%m-%d}";
                  tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
                };

                tray = {
                  icon-size = 21;
                  spacing = 10;
                };
              };
            };

            # Waybar CSS styling - Tokyo Night Storm
            "waybar/style.css" = {
              text = ''
                * {
                  font-family: "CaskaydiaCove Nerd Font";
                  font-size: 13px;
                  min-height: 0;
                }

                window#waybar {
                  background-color: rgba(26, 27, 38, 0.9);
                  color: #c0caf5;
                  transition-property: background-color;
                  transition-duration: .5s;
                  border-radius: 0px;
                }

                window#waybar.hidden {
                  opacity: 0.2;
                }

                #workspaces button {
                  padding: 0 8px;
                  background-color: transparent;
                  color: #565f89;
                  border: none;
                  border-radius: 4px;
                  margin: 0 2px;
                }

                #workspaces button:hover {
                  background-color: rgba(116, 199, 236, 0.2);
                  color: #7dcfff;
                }

                #workspaces button.active {
                  background-color: rgba(116, 199, 236, 0.3);
                  color: #7dcfff;
                }

                #mode {
                  background-color: rgba(248, 113, 133, 0.8);
                  border-bottom: 3px solid #f7768e;
                  color: #1a1b26;
                  margin: 0 4px;
                  padding: 0 12px;
                  border-radius: 4px;
                }

                #clock,
                #battery,
                #cpu,
                #memory,
                #disk,
                #temperature,
                #backlight,
                #network,
                #pulseaudio,
                #tray {
                  padding: 0 12px;
                  margin: 0 2px;
                  color: #c0caf5;
                  border-radius: 4px;
                }

                #window {
                  color: #7dcfff;
                  font-weight: bold;
                }

                #battery {
                  background-color: rgba(158, 206, 106, 0.15);
                  color: #9ece6a;
                }

                #battery.charging {
                  background-color: rgba(224, 175, 104, 0.15);
                  color: #e0af68;
                }

                #battery.critical:not(.charging) {
                  background-color: rgba(247, 118, 142, 0.15);
                  color: #f7768e;
                  animation-name: blink;
                  animation-duration: 0.5s;
                  animation-timing-function: linear;
                  animation-iteration-count: infinite;
                  animation-direction: alternate;
                }

                #cpu {
                  background-color: rgba(224, 175, 104, 0.15);
                  color: #e0af68;
                }

                #memory {
                  background-color: rgba(187, 154, 247, 0.15);
                  color: #bb9af7;
                }

                #disk {
                  background-color: rgba(125, 207, 255, 0.15);
                  color: #7dcfff;
                }

                #network {
                  background-color: rgba(158, 206, 106, 0.15);
                  color: #9ece6a;
                }

                #network.disconnected {
                  background-color: rgba(247, 118, 142, 0.15);
                  color: #f7768e;
                }

                #pulseaudio {
                  background-color: rgba(125, 207, 255, 0.15);
                  color: #7dcfff;
                }

                #pulseaudio.muted {
                  background-color: rgba(247, 118, 142, 0.15);
                  color: #f7768e;
                }

                #clock {
                  background-color: rgba(116, 199, 236, 0.15);
                  color: #7aa2f7;
                  font-weight: bold;
                }

                #tray > .passive {
                  -gtk-icon-effect: dim;
                }

                #tray > .needs-attention {
                  -gtk-icon-effect: highlight;
                  background-color: rgba(247, 118, 142, 0.15);
                }

                @keyframes blink {
                  to {
                    background-color: rgba(247, 118, 142, 0.5);
                    color: #ffffff;
                  }
                }
              '';
            };

            # Mako notification configuration - Tokyo Night Storm
            "mako/config" = {
              text = ''
                font=CaskaydiaCove Nerd Font 11
                background-color=#1a1b26
                text-color=#c0caf5
                border-color=#7aa2f7
                border-size=2
                border-radius=8
                default-timeout=5000
                ignore-timeout=1

                [urgency=high]
                border-color=#f7768e
                background-color=#1a1b26
                text-color=#f7768e
              '';
            };

            # Tokyo Night Day theme toggle script
            "hypr/toggle-theme.sh" = {
              text = ''
                #!/bin/bash

                CURRENT=$(cat ~/.config/hypr/current-theme 2>/dev/null || echo "storm")

                if [ "$CURRENT" = "storm" ]; then
                    # Switch to Tokyo Night Day
                    sed -i 's/rgba(7aa2f7ee) rgba(bb9af7ee)/rgba(2e7de9ee) rgba(188a6dee)/g' ~/.config/hypr/hyprland.conf
                    sed -i 's/rgba(565f89aa)/rgba(8990b3aa)/g' ~/.config/hypr/hyprland.conf
                    echo "day" > ~/.config/hypr/current-theme
                    notify-send "Theme switched to Tokyo Night Day"
                else
                    # Switch to Tokyo Night Storm
                    sed -i 's/rgba(2e7de9ee) rgba(188a6dee)/rgba(7aa2f7ee) rgba(bb9af7ee)/g' ~/.config/hypr/hyprland.conf
                    sed -i 's/rgba(8990b3aa)/rgba(565f89aa)/g' ~/.config/hypr/hyprland.conf
                    echo "storm" > ~/.config/hypr/current-theme
                    notify-send "Theme switched to Tokyo Night Storm"
                fi

                hyprctl reload
              '';
              executable = true;
            };
          };

          # Environment variables
          home.sessionVariables = {
            EDITOR = "nvim";
            BROWSER = "chromium";
            TERMINAL = "ghostty";
            # Wayland specific
            NIXOS_OZONE_WL = "1"; # Enable Wayland for Electron apps
            MOZ_ENABLE_WAYLAND = "1"; # Firefox Wayland
            QT_QPA_PLATFORM = "wayland";
            XDG_SESSION_TYPE = "wayland";
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
              rebuild = "home-manager switch --flake ~/.setup/arch#robb";
              ls = "eza --icons";
              ll = "eza -l --icons";
              la = "eza -la --icons";
              tree = "eza --tree --icons";
            };

            initExtra = ''
              # Mise activation
              eval "$(mise activate zsh)"

              # Add .NET Core SDK tools
              export PATH="$PATH:$HOME/.dotnet/tools"

              # Add custom bin to path
              export PATH="$HOME/.bin:$PATH"

              # Add Nix packages to path
              export PATH="$HOME/.nix-profile/bin:$PATH"

              # Load environment variables if they exist
              [ -f ~/.vars ] && . ~/.vars

              # Initialize starship
              eval "$(starship init zsh)"

              # System info on new shell (omarchy style)
              fastfetch
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

          programs.fzf = {
            enable = true;
            enableZshIntegration = true;
          };

          programs.bat = {
            enable = true;
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
        })
      ];
    };

    # Installation script as a Nix app
    apps.x86_64-linux.install = {
      type = "app";
      program = "${nixpkgs.legacyPackages.x86_64-linux.writeShellScript "install" ''
        set -e

        printf "\n🚀 Setting up your Arch Linux machine with Nix + Home Manager + Hyprland...\n\n"

        # Install essential system dependencies
        printf "📦 Installing system dependencies...\n"
        sudo pacman -Syu --noconfirm
        sudo pacman -S --noconfirm curl git xz ca-certificates base-devel

        # Install yay (AUR helper) if not present
        if ! command -v yay &> /dev/null; then
            printf "🔧 Installing yay AUR helper...\n"
            git clone https://aur.archlinux.org/yay.git /tmp/yay
            cd /tmp/yay
            makepkg -si --noconfirm
            cd -
            printf "✅ yay installed successfully\n"
        else
            printf "✅ yay already installed\n"
        fi

        # Install Nix if not already installed
        if [ ! -d "/nix" ]; then
            printf "🔧 Installing Nix package manager...\n"
            curl -L https://nixos.org/nix/install | sh
            printf "✅ Nix installed successfully\n"
        else
            printf "✅ Nix already installed\n"
        fi

        # Source Nix environment
        if [ -f ~/.nix-profile/etc/profile.d/nix.sh ]; then
            . ~/.nix-profile/etc/profile.d/nix.sh
            printf "✅ Nix environment loaded\n"
        else
            printf "❌ Nix profile not found. Please restart your shell and run this script again.\n"
            exit 1
        fi

        # Configure Nix with flakes
        printf "🔧 Configuring Nix with flakes support...\n"
        mkdir -p ~/.config/nix
        echo "experimental-features = nix-command flakes" > ~/.config/nix/nix.conf
        printf "✅ Flakes enabled\n"

        # Apply Home Manager configuration
        printf "🏠 Applying Home Manager configuration...\n"
        cd ~/.setup/arch
        nix run home-manager/master -- switch --flake .#robb
        printf "✅ Home Manager configuration applied successfully!\n"

        # Install GUI applications via yay/AUR that work better outside Nix
        printf "🖥️  Installing essential GUI applications via AUR...\n"

        # Development tools
        yay -S --noconfirm visual-studio-code-bin || printf "⚠️  Failed to install VS Code\n"
        yay -S --noconfirm cursor-bin || printf "⚠️  Failed to install Cursor\n"
        yay -S --noconfirm zed-bin || printf "⚠️  Failed to install Zed\n"

        # Communication & browsers
        yay -S --noconfirm discord || printf "⚠️  Failed to install Discord\n"
        yay -S --noconfirm vivaldi || printf "⚠️  Failed to install Vivaldi\n"
        yay -S --noconfirm zoom || printf "⚠️  Failed to install Zoom\n"

        # Productivity
        yay -S --noconfirm 1password || printf "⚠️  Failed to install 1Password\n"
        yay -S --noconfirm obsidian || printf "⚠️  Failed to install Obsidian\n"
        yay -S --noconfirm localsend-bin || printf "⚠️  Failed to install LocalSend\n"

        # Gaming
        yay -S --noconfirm steam || printf "⚠️  Failed to install Steam\n"

        # Enable essential services
        printf "🔧 Enabling essential services...\n"
        sudo systemctl --user enable pipewire pipewire-pulse wireplumber

        printf "\n🎉 Setup complete!\n\n"
        printf "Next steps:\n"
        printf "1. Restart your shell or run: source ~/.nix-profile/etc/profile.d/nix.sh\n"
        printf "2. Log out and select Hyprland as your session\n"
        printf "3. Your development tools are now managed by Home Manager\n"
        printf "4. To update your configuration: edit ~/.setup/arch/flake.nix and run 'rebuild'\n"
        printf "5. Use Super+R to open wofi launcher, Super+Enter for terminal\n\n"
        printf "🚀 Welcome to your new Arch + Nix + Hyprland setup!\n"
      ''}";
    };
  };
}

