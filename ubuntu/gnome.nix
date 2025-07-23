{ pkgs, ... }: {
  gtk = {
    enable = true;
    font = {
      name = "FiraCode Nerd Font";
      size = 10;
    };
  };

  home.packages = with pkgs; [
    gnomeExtensions.just-perfection
    gnomeExtensions.blur-my-shell
    gnomeExtensions.undecorate
    gnomeExtensions.dash-to-dock
    gnomeExtensions.space-bar
    gnomeExtensions.alphabetical-app-grid
    gnome-extension-manager
  ];

  dconf.settings =
    let
      inherit (pkgs.lib) mkOption;
      inherit (pkgs.lib.hm.gvariant) mkTuple;
    in
    {
      "org/gnome/shell" = {
        enabled-extensions = [
          "just-perfection-desktop@just-perfection"
          "blur-my-shell@aunetx"
          "undecorate@sun.wxg@gmail.com"
          "dash-to-dock@micxgx.gmail.com"
          "space-bar@luchrioh"
          "AlphabeticalAppGrid@stuarthayhurst"
        ];
        favorite-apps = [
          "ghostty.desktop"
          "1password.desktop"
          "com.claude.Claude.desktop"
          "io.beekeeperstudio.Studio.desktop"
          "com.usebruno.Bruno.desktop"
          "com.jetbrains.Rider.desktop"
          "com.discordapp.Discord.desktop"
          "us.zoom.Zoom.desktop"
          "com.vivaldi.Vivaldi.desktop"
          "com.github.PintaProject.Pinta.desktop"
          "com.obsproject.Studio.desktop"
          "org.localsend.localsend_app.desktop"
        ];
      };

      "org/gnome/shell/extensions/dash-to-dock" = {
        dock-position = "BOTTOM";
        dock-fixed = false;
        autohide = true;
        intellihide = false;
        dash-max-icon-size = 48;
        show-recents = false;
        show-applications-button = true;
        show-trash = false;
        hot-keys = false;
        autohide-in-fullscreen = true;
        require-pressure-to-show = false;
      };

      "org/gnome/shell/extensions/just-perfection" = {
        animation = 2;
        dash-app-running = true;
        workspace = true;
        workspace-popup = false;
        theme = true;
        startup-status = 0;
        workspace-switcher-should-show = false;
      };

      "org/gnome/shell/extensions/blur-my-shell" = {
        "appfolder/blur" = false;
        "lockscreen/blur" = false;
        "screenshot/blur" = false;
        "window-list/blur" = false;
        "panel/blur" = false;
        "overview/blur" = true;
        "overview/pipeline" = "pipeline_default";
        "dash-to-dock/blur" = true;
        "dash-to-dock/brightness" = 0.6;
        "dash-to-dock/sigma" = 30;
        "dash-to-dock/static-blur" = true;
        "dash-to-dock/style-dash-to-dock" = 0;
      };

      "org/gnome/shell/extensions/space-bar" = {
        "behavior/smart-workspace-names" = false;
        "shortcuts/enable-activate-workspace-shortcuts" = false;
        "shortcuts/enable-move-to-workspace-shortcuts" = true;
        "shortcuts/open-menu" = "@as []";
        "appearance/workspace-margin" = 8;
        "behavior/show-empty-workspaces" = true;
      };

      "org/gnome/shell/extensions/alphabetical-app-grid" = {
        folder-order-position = "end";
      };

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
        switch-to-application-1 = [ ];
        switch-to-application-2 = [ ];
        switch-to-application-3 = [ ];
        switch-to-application-4 = [ ];
        switch-to-application-5 = [ ];
        switch-to-application-6 = [ ];
        switch-to-application-7 = [ ];
        switch-to-application-8 = [ ];
        switch-to-application-9 = [ ];
      };
      "org/gnome/settings-daemon/plugins/media-keys" = {
        next = [ "<Shift>AudioPlay" ];
        screenshot = [ ];
        screenshot-clip = [ ];
        area-screenshot = [ ];
        area-screenshot-clip = [ ];
        window-screenshot = [ ];
        window-screenshot-clip = [ ];
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
        binding = "Print";
      };


      "org/gnome/mutter" = {
        dynamic-workspaces = false;
        workspaces-only-on-primary = false;
        center-new-windows = true;
      };
      "org/gnome/desktop/wm/preferences" = {
        num-workspaces = 6;
      };
      "org/gnome/shell/app-switcher" = {
        current-workspace-only = true;
      };
      "org/gnome/desktop/interface" = {
        monospace-font-name = "FiraCode Nerd Font 10";
        show-battery-percentage = true;
      };
      "org/gnome/desktop/peripherals/touchpad" = {
        click-method = "fingers";
      };
      "org/gnome/desktop/input-sources" = {
        xkb-options = [ "caps:ctrl_modifier" ];
      };
      "org/gnome/desktop/calendar" = {
        show-weekdate = true;
      };
      "org/gnome/gnome-screenshot" = {
        auto-save-directory = "file:///home/robb/Pictures/screenshots";
      };
    };

  home.file.".1password/custom_allowed_browsers".text = ''
    vivaldi-bin
  '';

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

