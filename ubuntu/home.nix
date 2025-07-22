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
      zstyle ':completion:*' group-name

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

