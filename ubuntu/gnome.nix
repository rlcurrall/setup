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
      col-0 = 1;
      col-1 = 2;
      col-2 = 1;
      col-3 = 0;
      row-0 = 1;
      row-1 = 1;
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

  # == AUTOSTART ==
  # Enable ulauncher to start automatically
  xdg.configFile."autostart/ulauncher.desktop".text = ''
    [Desktop Entry]
    Name=Ulauncher
    Comment=Application launcher for Linux
    GenericName=Launcher
    Categories=GNOME;GTK;Utility;
    TryExec=ulauncher
    Exec=ulauncher --hide-window
    Icon=ulauncher
    Terminal=false
    Type=Application
    X-GNOME-Autostart-enabled=true
  '';
}

