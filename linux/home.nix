{ config, pkgs, ... }: {
  # Home Manager needs a bit of information about you and the paths it should manage
  home.username = "robb";
  home.homeDirectory = "/home/robb";
  home.stateVersion = "24.05";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Disable version mismatch warning
  home.enableNixpkgsReleaseCheck = false;

  # Packages installed in user profile
  home.packages = with pkgs; [
    # CLI Tools (from Mac config)
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

    # Development Tools
    uv
    zig
    rustup
    just

    # System Tools
    btop
    vim
    neovim
    lazygit
    lazydocker
    ffmpeg
    docker
    tailscale

    # AI/ML Tools
    llama-cpp
    ollama

    # Fonts
    fira-code
    fira-code-symbols
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.hack

    # GUI Applications (available in nixpkgs)
    ghostty # Terminal emulator
    flameshot # Screenshot tool
    ulauncher # Application launcher (Linux equivalent of Raycast)
    obs-studio # Professional screen recording and streaming

    # Development tools with GUI
    # Note: Some GUI apps work better via snap/flatpak for desktop integration
  ];

  # Create Code directory
  home.file."Code/.keep".text = "";

  # Dotfiles management - link to shared config
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

    "ulauncher/user-preferences.json" = {
      source = ../config/ulauncher/settings.json;
    };

    "autostart/ulauncher.desktop" = {
      source = ../config/ulauncher/ulauncher.desktop;
    };
  };

  # Environment variables
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
      rebuild = "home-manager switch --flake ~/.setup/linux#robb";
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
    userEmail = "rlcurrall@gmail.com"; # Replace with your actual email
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

  # Auto-install mise tools during home-manager activation
  home.activation.miseInstall = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD ${pkgs.mise}/bin/mise install
  '';

  # GNOME configuration via dconf
  dconf.settings = {
    # Custom keybindings for applications
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
      ];
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      name = "Ulauncher";
      command = "ulauncher-toggle";
      binding = "<Super>space";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
      name = "Flameshot";
      command = "sh -c -- \"flameshot gui\"";
      binding = "<Control>Print";
    };

    # Window management keybindings
    "org/gnome/desktop/wm/keybindings" = {
      close = [ "<Super>w" ];
      maximize = [ "<Super>Up" ];
      begin-resize = [ "<Super>BackSpace" ];
      toggle-fullscreen = [ "<Shift>F11" ];
      switch-input-source = [ ]; # Clear default Super+Space binding

      # Workspace switching with Super+1-6
      switch-to-workspace-1 = [ "<Super>1" ];
      switch-to-workspace-2 = [ "<Super>2" ];
      switch-to-workspace-3 = [ "<Super>3" ];
      switch-to-workspace-4 = [ "<Super>4" ];
      switch-to-workspace-5 = [ "<Super>5" ];
      switch-to-workspace-6 = [ "<Super>6" ];
    };

    # Application switching with Alt+1-9
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

    # Workspace management
    "org/gnome/mutter" = {
      dynamic-workspaces = false;
      center-new-windows = true;
    };

    "org/gnome/desktop/wm/preferences" = {
      num-workspaces = 6;
    };

    # UI improvements
    "org/gnome/desktop/interface" = {
      monospace-font-name = "FiraCode Nerd Font 10";
    };

    "org/gnome/desktop/calendar" = {
      show-weekdate = true;
    };

    # Disable ambient brightness sensor (often problematic)
    "org/gnome/settings-daemon/plugins/power" = {
      ambient-enabled = false;
    };

    # App folder organization for cleaner app grid
    "org/gnome/desktop/app-folders" = {
      folder-children = [ "Utilities" "Updates" "Development" "Office" "Graphics" ];
    };

    "org/gnome/desktop/app-folders/folders/Utilities" = {
      name = "Utilities";
      apps = [
        "org.gnome.SystemMonitor.desktop"
        "org.gnome.DiskUtility.desktop"
        "org.gnome.FileRoller.desktop"
        "org.gnome.Calculator.desktop"
        "org.gnome.Characters.desktop"
        "org.gnome.Logs.desktop"
        "yelp.desktop"
      ];
    };

    "org/gnome/desktop/app-folders/folders/Updates" = {
      name = "Install & Update";
      apps = [
        "org.gnome.Software.desktop"
        "software-properties-drivers.desktop"
        "software-properties-gtk.desktop"
        "update-manager.desktop"
        "firmware-updater_firmware-updater.desktop"
        "snap-store_snap-store.desktop"
      ];
    };

    "org/gnome/desktop/app-folders/folders/Development" = {
      name = "Development";
      apps = [
        "code.desktop"
        "cursor.desktop"
        "zed.desktop"
        "rider.desktop"
        "nvim.desktop"
        "btop.desktop"
        "Docker.desktop"
      ];
    };

    "org/gnome/desktop/app-folders/folders/Office" = {
      name = "Office";
      apps = [
        "libreoffice-base.desktop"
        "libreoffice-calc.desktop"
        "libreoffice-draw.desktop"
        "libreoffice-impress.desktop"
        "libreoffice-math.desktop"
        "libreoffice-startcenter.desktop"
        "libreoffice-writer.desktop"
        "md.obsidian.Obsidian.desktop"
      ];
    };

    "org/gnome/desktop/app-folders/folders/Graphics" = {
      name = "Graphics";
      apps = [
        "org.gnome.eog.desktop"
        "pinta_pinta.desktop"
        "org.flameshot.Flameshot.desktop"
        "gimp.desktop"
        "com.obsproject.Studio.desktop"
      ];
    };

    # GNOME Extensions (must be manually installed first)
    # Just Perfection extension settings
    "org/gnome/shell/extensions/just-perfection" = {
      animation = 2; # Faster animations
      dash-app-running = true; # Show running app indicators
      workspace = true; # Show workspace indicator
      workspace-popup = false; # Disable workspace popup
    };

    # Blur My Shell extension settings
    "org/gnome/shell/extensions/blur-my-shell/appfolder" = {
      blur = false;
    };
    "org/gnome/shell/extensions/blur-my-shell/lockscreen" = {
      blur = false;
    };
    "org/gnome/shell/extensions/blur-my-shell/screenshot" = {
      blur = false;
    };
    "org/gnome/shell/extensions/blur-my-shell/window-list" = {
      blur = false;
    };
    "org/gnome/shell/extensions/blur-my-shell/panel" = {
      blur = false;
    };
    "org/gnome/shell/extensions/blur-my-shell/overview" = {
      blur = true;
      pipeline = "pipeline_default";
    };
    "org/gnome/shell/extensions/blur-my-shell/dash-to-dock" = {
      blur = true;
      brightness = 0.6;
      sigma = 30;
      static-blur = true;
      style-dash-to-dock = 0;
    };
  };

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;
}

