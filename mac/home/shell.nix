{ lib, home, profile, ... }:
{
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
      rebuild = "bash ~/.setup/mac/rebuild.sh ${profile}";
      lg = "lazygit";
    };

    # Oh My Zsh initializes completions at order 800. Add optional completion
    # directories first so compinit runs once, including on a fresh machine.
    initContent = lib.mkMerge [
      (lib.mkOrder 790 ''
        if [[ -d "${home}/.docker/completions" ]]; then
          fpath=("${home}/.docker/completions" $fpath)
        fi
      '')
      ''
        eval "$(mise activate zsh)"
        export PATH="$PATH:$HOME/.dotnet/tools"
        export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
        export PATH="$HOME/.bin:$PATH"
        export PATH="$HOME/.local/bin:$PATH"
        [ -f ~/.vars ] && . ~/.vars
      ''
    ];
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

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
}
