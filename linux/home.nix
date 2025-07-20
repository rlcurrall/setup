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
    go
    zig
    rustup
    just

    # System Tools
    btop
    vim
    neovim
    lazygit
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
  home.activation.miseInstall = config.lib.dag.entryAfter ["writeBoundary"] ''
    $DRY_RUN_CMD ${pkgs.mise}/bin/mise install
  '';

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;
}

