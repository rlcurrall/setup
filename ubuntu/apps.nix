{ pkgs, ghostty, ... }: {
  home.packages = with pkgs; [
    # CLI Tools
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
    gh
    curl
    wget
    unzip
    file
    xclip
    tldr
    eza

    # Development Tools
    uv
    zig
    rustup
    just
    dotnet-sdk

    # System Tools
    btop
    vim
    neovim
    lazygit
    lazydocker
    ffmpeg
    imagemagick

    # AI/ML Tools
    tailscale
    llama-cpp
    ollama

    # GUI Apps
    flameshot
    ulauncher
    _1password-cli
    _1password-gui
    vlc
    sushi
    cheese
    gnome-tweaks
    dconf-editor
    chrome-gnome-shell
    ghostty.packages.${pkgs.stdenv.hostPlatform.system}.default

    # Fonts
    fira-code
    fira-code-symbols
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.hack
  ];

  # Font configuration
  fonts.fontconfig.enable = true;

  # Enable Flatpak font access
  services.flatpak = {
    enable = true;
    packages = [
      { appId = "com.claude.Claude"; }
      { appId = "io.beekeeperstudio.Studio"; }
      { appId = "com.usebruno.Bruno"; }
      { appId = "com.visualstudio.code"; }
      { appId = "dev.zed.Zed"; }
      { appId = "com.cursor.Cursor"; }
      { appId = "com.jetbrains.Rider"; }
      { appId = "com.discordapp.Discord"; }
      { appId = "us.zoom.Zoom"; }
      { appId = "com.vivaldi.Vivaldi"; }
      { appId = "com.github.PintaProject.Pinta"; }
      { appId = "com.obsproject.Studio"; }
      { appId = "org.localsend.localsend_app"; }
      { appId = "com.valvesoftware.Steam"; }
      { appId = "com.spotify.Client"; }
    ];

    # Grant Flatpak apps access to fonts
    overrides = {
      global = {
        # Allow access to fonts and icons
        filesystems = [
          "~/.local/share/fonts:ro"
          "~/.icons:ro"
          "/nix/store:ro"
        ];
      };
    };
  };

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
      icon = "docker";
      categories = [ "Utility" "System" "Development" ];
    };
  };
}

