{ config, lib, pkgs, ... }:
let
  me = config.system.primaryUser;
  home = "/Users/${me}";

  # Run `<tool> init zsh` once at build time instead of on every shell start.
  # Defender/WithSecure scan each process launch, which made startup take 10s+.
  initScript = name: cmd:
    pkgs.runCommand "${name}-init.zsh"
      { nativeBuildInputs = [ pkgs.writableTmpDirAsHomeHook ]; }
      "${cmd} > $out";
in {
  # Machine-specific packages and settings go here.

  home-manager.users.${me} = { config, ... }: {
    # Replaced by the pre-generated scripts below
    programs.starship.enableZshIntegration = lib.mkForce false;
    programs.atuin.enableZshIntegration = lib.mkForce false;
    programs.zoxide.enableZshIntegration = lib.mkForce false;

    programs.zsh.initContent = lib.mkMerge [
      # Before oh-my-zsh (800) so its compinit picks up Homebrew and Docker
      # completions, avoiding a second compinit. Skip compaudit's permission checks.
      (lib.mkOrder 790 ''
        ZSH_DISABLE_COMPFIX=true

        # Output of `brew shellenv`, inlined to skip a process at startup
        export HOMEBREW_PREFIX="/opt/homebrew";
        export HOMEBREW_CELLAR="/opt/homebrew/Cellar";
        export HOMEBREW_REPOSITORY="/opt/homebrew";
        fpath[1,0]="/opt/homebrew/share/zsh/site-functions";
        export FPATH;
        export PATH="/opt/homebrew/bin:/opt/homebrew/sbin''${PATH+:$PATH}";
        [ -z "''${MANPATH-}" ] || { export MANPATH="''${MANPATH%"''${MANPATH##*[!:]}"}"; export MANPATH=":''${MANPATH#"''${MANPATH%%[!:]*}"}"; };
        export INFOPATH="/opt/homebrew/share/info:''${INFOPATH:-}";

        fpath=(${home}/.docker/completions $fpath)
      '')

      # Same position as the home-manager zoxide integration (after compinit)
      (lib.mkOrder 851 ''
        source ${initScript "zoxide" "${lib.getExe config.programs.zoxide.package} init zsh"}
      '')

      ''
        if [[ $TERM != "dumb" ]]; then
          source ${initScript "starship" "${lib.getExe config.programs.starship.package} init zsh --print-full-init"}
        fi

        if [[ $options[zle] = on ]]; then
          source ${initScript "atuin" "${lib.getExe config.programs.atuin.package} init zsh"}
        fi
      ''
    ];
  };
}
