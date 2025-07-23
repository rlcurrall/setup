{ config, pkgs, ... }: {
  home.username = "robb";
  home.homeDirectory = "/home/robb";
  home.stateVersion = "24.05";
  nixpkgs.config.allowUnfree = true;
  home.enableNixpkgsReleaseCheck = false;

  # Dotfile linking
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
    "ulauncher" = {
      source = ../config/ulauncher;
      recursive = true;
    };
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "vivaldi";
    TERMINAL = "ghostty";
  };

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
      ls = "eza -lh --group-directories-first --icons=auto";
      lsa = "ls -a";
      lt = "eza --tree --level=2 --long --icons --git";
      ff = "fzf --preview 'bat --style=numbers --color=always {}'";
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      n = "nvim";
      g = "git";
      d = "docker";
      lzg = "lazygit";
      lzd = "lazydocker";
      rebuild = "(cd ~/.setup/ubuntu && home-manager switch --flake .#robb)";
    };

    initContent = ''
      eval "$(mise activate zsh)"
      [ -d "$HOME/.bin" ] && export PATH="$HOME/.bin:$PATH"
      [ -f ~/.vars ] && . ~/.vars
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

  home.activation.miseInstall = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD ${pkgs.mise}/bin/mise install
  '';

  # Create font symlink for Flatpak apps
  home.activation.setupFonts = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD mkdir -p $HOME/.local/share/fonts
    $DRY_RUN_CMD ln -sf ${config.home.profileDirectory}/share/fonts/* $HOME/.local/share/fonts/ 2>/dev/null || true
  '';

  programs.home-manager.enable = true;
}

