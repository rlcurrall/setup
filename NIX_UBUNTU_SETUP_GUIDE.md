# Guide: Building a Declarative Ubuntu Setup with Nix

This document outlines a strategy to refactor your current Nix-based Ubuntu setup into a robust, modular, and declarative system. It uses your excellent `nix-darwin` Mac setup as a blueprint and combines its principles with the modularity of the Omakub project.

## 1. The Goal: Parity with Your Mac Setup

Your Mac setup is the gold standard. Its "completeness" comes from using `nix-darwin` to declaratively manage the entire system. Our goal is to replicate this experience on Ubuntu as closely as possible.

- **The `nix-darwin` Analogy:** On macOS, you have `nix-darwin`. The equivalent for a Linux distribution is `NixOS`. Since you are on Ubuntu, we will use **Home Manager** as our primary tool. While it can't manage the OS kernel, it gives us powerful control over your entire user environment, which is where most customization happens.
- **The `homebrew` Cask Analogy:** Your Mac setup pragmatically uses Homebrew Casks for GUI applications. We will achieve the same result on Ubuntu by using **Flatpak**, managed declaratively through Nix. This is the best-in-class solution for Linux GUI apps.
- **Improving on the Monolithic Flake:** Your Mac `flake.nix` is comprehensive. We can make the Ubuntu version even more maintainable by splitting it into logical modules, an idea borrowed from the clean structure of Omakub.

## 2. Proposed Architecture

We will restructure your configuration to be modular, fully declarative, and mirror the capabilities of your Mac setup.

### A. A Single, Simple Installer

Your installation script will do only three things: install Nix, clone your `.setup` repo, and run Home Manager. All complexity moves into Nix.

### B. Modular Flake Configuration

Just as Omakub has `install/terminal` and `install/desktop`, we will split your `flake.nix` into logical modules.

```
ubuntu/
├── flake.nix       # Main flake, imports modules
├── home.nix        # Core user settings, shell, CLI tools (like your mac's home-manager section)
├── gnome.nix       # All GNOME settings, keybindings, themes, and dock items (like your mac's system.defaults)
└── apps.nix        # GUI application management via Nix and Flatpak (like your mac's homebrew.casks)
```
*(Note: The `ulauncher` fix is now integrated directly into `gnome.nix` and `apps.nix`)*

## 3. Step-by-Step Refactoring Guide

Here is a concrete plan to implement the new architecture.

### Step 1: Create a Unified Installer

To achieve a one-command setup, we'll consolidate all installation logic into a single, robust script. This script will replace `ubuntu/bootstrap.sh` and `ubuntu/install.sh`.

1.  **Delete the old scripts:**
    ```bash
    rm ubuntu/bootstrap.sh
    ```
    You should also remove the `apps` output from your `ubuntu/flake.nix`, as application installation will now be handled declaratively by Home Manager and `flatpak-nix`.

2.  **Create `ubuntu/install.sh`:**
    Replace the content of `ubuntu/install.sh` with this unified script. It's designed to be idempotent and can be run on a fresh Ubuntu system.

    ```bash
    #!/bin/bash
    set -e

    # This script bootstraps the declarative Ubuntu setup.
    # It can be run directly from GitHub:
    # wget -O - https://raw.githubusercontent.com/rlcurrall/setup/main/ubuntu/install.sh | bash

    print_step() {
        echo -e "\n🚀 $1"
    }

    # 0. Install essential dependencies
    # We need git to clone the repo and curl to download installers.
    print_step "Installing essential dependencies (git, curl)..."
    sudo apt-get update -y
    sudo apt-get install -y git curl

    # 1. Install Nix
    if ! command -v nix &> /dev/null; then
        print_step "Installing Nix package manager..."
        # Using the Determinate Systems installer for its reliability and speed.
        curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
        # Source the nix profile to make the 'nix' command available in this script session.
        . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    else
        echo "✅ Nix is already installed."
    fi

    # 2. Enable Flakes (idempotent)
    print_step "Enabling Nix Flakes support..."
    mkdir -p "$HOME/.config/nix"
    # Check if the feature is already enabled to avoid unnecessary writes
    if ! grep -q "experimental-features = nix-command flakes" "$HOME/.config/nix/nix.conf" 2>/dev/null; then
        echo "experimental-features = nix-command flakes" >> "$HOME/.config/nix/nix.conf"
    fi

    # 3. Clone or update the setup repository
    SETUP_DIR="$HOME/.setup"
    if [ ! -d "$SETUP_DIR" ]; then
        print_step "Cloning setup repository..."
        git clone https://github.com/rlcurrall/setup.git "$SETUP_DIR"
    else
        print_step "Setup repository already exists. Pulling latest changes..."
        cd "$SETUP_DIR"
        git pull
    fi

    # 4. Build the Home Manager configuration
    print_step "Applying the declarative Home Manager configuration..."
    cd "$SETUP_DIR/ubuntu"
    nix run home-manager/master -- switch --flake .#robb

    echo -e "\n✅ Setup complete! Please restart your shell or log out and back in for all changes to take effect."
    ```

### Step 2: Update and Modularize Your Flake

Replace your `ubuntu/flake.nix` with this modular version. It adds `flatpak-nix` for declarative Flatpak management.

```nix
{
  description = "Home Manager configuration for Robb on Ubuntu";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flatpak-nix.url = "github:gmodena/flatpak-nix";
  };

  outputs = { nixpkgs, home-manager, flatpak-nix, ... }: {
    homeConfigurations.robb = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [
        # Import our modular configuration files
        ./home.nix
        ./gnome.nix
        ./apps.nix

        # Enable declarative flatpak support
        flatpak-nix.homeManagerModules.flatpak
      ];
    };
  };
}
```

### Step 3: Create the Module Files

Create the new `.nix` files in the `ubuntu/` directory.

**`ubuntu/apps.nix`** (Manages all applications, like `homebrew` in your Mac flake)

```nix
{ pkgs, ... }: {
  # Nix-native packages (mostly CLI tools and essential apps)
  home.packages = with pkgs; [
    # Core CLI Tools (from your Mac config)
    zsh git jq ripgrep fzf bat atuin fd zellij starship mise zoxide
    gh pulumi sst azure-functions-core-tools powershell

    # Development Runtimes & Tools
    uv zig rustup just dotnet-sdk

    # System & Utility Tools
    btop vim neovim lazygit lazydocker ffmpeg docker tailscale

    # AI/ML Tools
    llama-cpp ollama

    # Essential GUI apps that work well from nixpkgs
    ghostty
    flameshot
    ulauncher # We install it here
    rider # JetBrains Rider IDE
  ];

  # Flatpak for GUI apps (the equivalent of homebrew casks)
  services.flatpak.packages = [
    # Browsers & Communication
    { appId = "com.google.Chrome"; }
    { appId = "com.vivaldi.Vivaldi"; }
    { appId = "com.discordapp.Discord"; }
    { appId = "us.zoom.Zoom"; }

    # Development & Productivity
    { appId = "com.visualstudio.code"; }
    { appId = "com.cursor.Cursor"; }
    { appId = "dev.zed.Zed"; }
    { appId = "com.claude.Claude"; }
    { appId = "com.usebruno.Bruno"; } # API Client
    { appId = "io.dbeaver.DBeaverCommunity"; } # Database GUI (alternative to TablePlus)
    { appId = "com.1password.1Password"; }
    { appId = "org.localsend.localsend_app"; }

    # Creative & Gaming
    { appId = "com.github.PintaProject.Pinta"; }
    { appId = "com.obsproject.Studio"; }
    { appId = "com.mojang.Minecraft"; }
    { appId = "com.valvesoftware.Steam"; }
  ];

  # Create .desktop files for terminal apps to launch them from the app grid
  xdg.desktopEntries = {
    "Neovim" = {
      name = "Neovim";
      comment = "Edit text files";
      exec = "ghostty -e nvim %F";
      terminal = false;
      icon = "nvim";
      categories = [ "Utility" "TextEditor" "Development" ];
    };
    "Activity" = {
      name = "Activity";
      comment = "System activity from btop";
      exec = "ghostty -e btop";
      terminal = false;
      icon = "utilities-system-monitor";
      categories = [ "Utility" "System" ];
    };
    "LazyDocker" = {
      name = "Docker";
      comment = "Manage Docker containers with LazyDocker";
      exec = "ghostty -e lazydocker";
      terminal = false;
      # You may need to install a docker icon for this to look right
      icon = "docker";
      categories = [ "Utility" "System" "Development" ];
    };
  };
}
```

**`ubuntu/gnome.nix`** (Manages GNOME, like `system.defaults` in your Mac flake)

```nix
{ pkgs, ... }: {
  # == THEMES & APPEARANCE ==
  # This section handles the visual look and feel of your desktop.
  gtk = {
    enable = true;
    font = {
      name = "FiraCode Nerd Font";
      size = 10;
    };
    theme = {
      name = "Tokyonight-B-Dark"; # Omakub's default theme
      package = pkgs.tokyo-night-gtk-theme;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };

  # == GNOME EXTENSIONS ==
  # A fully declarative approach to managing extensions.
  # 1. Install the extension packages.
  home.packages = with pkgs; [
    gnomeExtensions.dash-to-dock
    gnomeExtensions.tactile
    gnomeExtensions.just-perfection-desktop
    gnomeExtensions.blur-my-shell
    gnomeExtensions.space-bar
    gnomeExtensions.undecorate
    gnomeExtensions.tophat
    gnomeExtensions.alphabetical-app-grid
    # Also install themes here so they are available to the system
    tokyo-night-gtk-theme
    papirus-icon-theme
  ];

  # 2. Enable and configure the extensions using dconf.
  dconf.settings = {
    # 3. List the UUIDs of the extensions you want to enable.
    "org/gnome/shell" = {
      enabled-extensions = [
        "dash-to-dock@micxgx.gmail.com"
        "tactile@lundal.io"
        "just-perfection-desktop@just-perfection"
        "blur-my-shell@aunetx"
        "space-bar@luchrioh"
        "undecorate@sun.wxg@gmail.com"
        "tophat@fflewddur.github.io"
        "AlphabeticalAppGrid@stuarthayhurst"
      ];
      # Pin favorite apps to the dock, mirroring your Mac setup
      favorite-apps = [
        "ghostty.desktop"
        "com.1password.1Password.desktop"
        "com.claude.Claude.desktop"
        "io.dbeaver.DBeaverCommunity.desktop"
        "com.usebruno.Bruno.desktop"
        "com.discordapp.Discord.desktop"
        "us.zoom.Zoom.desktop"
        "com.vivaldi.Vivaldi.desktop"
        "com.github.PintaProject.Pinta.desktop"
        "com.obsproject.Studio.desktop"
        "org.localsend.localsend_app.desktop"
      ];
    };

    # == EXTENSION CONFIGURATION ==
    # Configure Dash to Dock for a macOS-style experience
    "org/gnome/shell/extensions/dash-to-dock" = {
      dock-position = "BOTTOM";
      dock-fixed = false;
      intellihide = true;
      dash-max-icon-size = 48;
      show-recents = false;
    };

    "org/gnome/shell/extensions/tactile" = {
      col-0 = 1; col-1 = 2; col-2 = 1; col-3 = 0;
      row-0 = 1; row-1 = 1;
      gap-size = 32;
    };
    "org/gnome/shell/extensions/just-perfection" = {
      animation = 2;
      dash-app-running = true;
      workspace = true;
      workspace-popup = false;
    };
    "org/gnome/shell/extensions/blur-my-shell" = {
      "appfolder/blur" = false;
      "lockscreen/blur" = false;
      "screenshot/blur" = false;
      "window-list/blur" = false;
      "panel/blur" = false;
      "overview/blur" = true;
      "dash-to-dock/blur" = true;
      "dash-to-dock/brightness" = 0.6;
      "dash-to-dock/sigma" = 30;
      "dash-to-dock/static-blur" = true;
    };
    "org/gnome/shell/extensions/space-bar" = {
      "behavior/smart-workspace-names" = false;
      "shortcuts/enable-activate-workspace-shortcuts" = false;
      "shortcuts/enable-move-to-workspace-shortcuts" = true;
      "shortcuts/open-menu" = "@as []";
    };
    "org/gnome/shell/extensions/tophat" = {
      show-icons = false;
      show-cpu = false;
      show-disk = false;
      show-mem = false;
      show-fs = false;
      network-usage-unit = "bits";
    };
    "org/gnome/shell/extensions/alphabetical-app-grid" = {
      folder-order-position = "end";
    };

    # == APP FOLDERS ==
    # Organize the app grid into folders, like Omakub.
    "org/gnome/desktop/app-folders" = {
      folder-children = [ "Utilities" "Updates" "Development" "Office" "Graphics" ];
    };
    "org/gnome/desktop/app-folders/folders/Utilities" = {
      name = "Utilities";
      apps = [ "org.gnome.Calculator.desktop" "org.gnome.Characters.desktop" "org.gnome.Logs.desktop" ];
    };
    # ... add other folders as desired ...

    # == KEYBINDINGS ==
    # Replicate Omakub's keyboard-driven workflow.
    "org/gnome/desktop/wm/keybindings" = {
      close = [ "<Super>w" ];
      maximize = [ "<Super>Up" ];
      begin-resize = [ "<Super>BackSpace" ];
      toggle-fullscreen = [ "<Shift>F11" ];
      switch-to-workspace-1 = [ "<Super>1" ];
      switch-to-workspace-2 = [ "<Super>2" ];
      switch-to-workspace-3 = [ "<Super>3" ];
      switch-to-workspace-4 = [ "<Super>4" ];
      switch-to-workspace-5 = [ "<Super>5" ];
      switch-to-workspace-6 = [ "<Super>6" ];
    };
    "org/gnome/shell/keybindings" = {
      switch-to-application-1 = [ "<Alt>1" ];
      switch-to-application-2 = [ "<Alt>2" ];
      switch-to-application-3 = [ "<Alt>3" ];
      switch-to-application-4 = [ "<Alt>4" ];
      switch-to-application-5 = [ "<Alt>5" ];
      switch-to-application-6 = [ "<Alt>6" ];
      switch-to-application-7 = [ "<Alt>7" ];
      switch-to-application-8 = [ "<Alt>8" ];
      switch-to-application-9 = [ "<Alt>9" ];
    };
    "org/gnome/settings-daemon/plugins/media-keys" = {
      next = [ "<Shift>AudioPlay" ];
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
      ];
      "custom-keybindings/custom0" = { name = "Ulauncher"; command = "ulauncher-toggle"; binding = "<Super>space"; };
      "custom-keybindings/custom1" = { name = "Flameshot"; command = "sh -c -- \"flameshot gui\""; binding = "<Control>Print"; };
      "custom-keybindings/custom2" = { name = "New Terminal"; command = "ghostty"; binding = "<Shift><Alt>2"; };
    };

    # == SYSTEM & WORKSPACE SETTINGS (from Mac setup) ==
    "org/gnome/mutter" = {
      dynamic-workspaces = false;
      center-new-windows = true;
    };
    "org/gnome/desktop/wm/preferences" = {
      num-workspaces = 6;
    };
    "org/gnome/desktop/interface" = {
      monospace-font-name = "FiraCode Nerd Font 10";
    };
    "org/gnome/desktop/calendar" = {
      show-weekdate = true;
    };
    "org/gnome/settings-daemon/plugins/power" = {
      ambient-enabled = false;
    };
    "org.gnome.desktop.screensaver" = {
      lock-delay = 10; # Corresponds to askForPasswordDelay
    };
    "org.gnome.shell.extensions.screenshot" = {
      # Note: This is for the built-in GNOME screenshot tool.
      # Flameshot has its own settings.
      auto-save-directory = "file:///home/robb/Pictures/screenshots";
    };
    "org.gnome.nautilus.preferences" = {
      # Corresponds to Finder preferences
      show-hidden-files = true;
      default-folder-viewer = "list-view";
    };
  };

  # == SERVICES ==
  # Enable the ulauncher service. This is the declarative fix.
  services.ulauncher = {
    enable = true;
    settings = {
      "clear-previous-query" = true;
      "show-indicator-icon" = true;
      "theme-name" = "dark";
    };
  };
}
```

**`ubuntu/home.nix`** (Core user environment, same as your Mac's `home-manager` section)

```nix
{ config, pkgs, ... }: {
  home.username = "robb";
  home.homeDirectory = "/home/robb";
  home.stateVersion = "24.05";
  nixpkgs.config.allowUnfree = true;
  home.enableNixpkgsReleaseCheck = false;

  # Dotfile linking (identical to your Mac setup)
  xdg.configFile = {
    "nvim".source = ../config/nvim;
    "btop".source = ../config/btop;
    "lazygit".source = ../config/lazygit;
    "ghostty".source = ../config/ghostty;
    "mise".source = ../config/mise;
    "zellij".source = ../config/zellij;
  };

  # Environment variables
  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "vivaldi";
    TERMINAL = "ghostty";
  };

  # Zsh, Oh My Zsh, and Omakub-inspired enhancements
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    oh-my-zsh = {
      enable = true;
      # Add history-substring-search to get the "type and press up" behavior
      plugins = [ "git" "history-substring-search" ];
    };
    shellAliases = {
      # Omakub Aliases
      ls = "eza -lh --group-directories-first --icons=auto";
      lsa = "ls -a";
      lt = "eza --tree --level=2 --long --icons --git";
      lta = "lt -a";
      ff = "fzf --preview 'bat --style=numbers --color=always {}'";
      fd = "fdfind";
      cd = "z";
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      n = "nvim";
      g = "git";
      d = "docker";
      r = "rails";
      bat = "batcat";
      lzg = "lazygit";
      lzd = "lazydocker";
      gcm = "git commit -m";
      gcam = "git commit -a -m";
      gcad = "git commit -a --amend";
      # Custom Aliases
      rebuild = "(cd ~/.setup/ubuntu && home-manager switch --flake .#robb)";
    };
    initExtra = ''
      # Zsh-native settings inspired by Omakub's inputrc
      # Case-insensitive completion
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
      # Group completions by type
      zstyle ':completion:*' group-name ''

      # Add custom bin to path (from your Mac setup)
      [ -d "$HOME/.bin" ] && export PATH="$HOME/.bin:$PATH"

      # Load local environment variables if they exist (from your Mac setup)
      [ -f ~/.vars ] && . ~/.vars

      # Mise activation
      eval "$(mise activate zsh)"
      # Initialize starship
      eval "$(starship init zsh)"
    '';
  };

  # Other program configurations
  programs.starship.enable = true;
  programs.atuin = {
    enable = true;
    settings = { enter_accept = true; sync.records = true; };
  };
  programs.git = {
    enable = true;
    userName = "Robb Currall";
    userEmail = "rlcurrall@gmail.com";
  };
  programs.zoxide.enable = true;

  # Let Home Manager manage itself
  programs.home-manager.enable = true;
}
```

### Step 4: Run the Installer

After creating these files and deleting the old ones, run the new `ubuntu/install.sh` script. Home Manager will build the new, modular configuration. Your system will now be managed in a way that is directly analogous to your Mac setup, resolving the `ulauncher` issue and giving you a clean, powerful, and declarative foundation.
