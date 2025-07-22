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