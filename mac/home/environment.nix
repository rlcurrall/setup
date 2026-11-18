{ config, home, ... }:
{
  # Shims also make developer tools available to non-interactive shells.
  home.sessionPath = [ "${config.xdg.dataHome}/mise/shims" ];

  home.sessionVariables = {
    ANDROID_HOME = "${home}/Library/Android/sdk";
    ANDROID_SDK_ROOT = "${home}/Library/Android/sdk";
    EDITOR = "nvim";
    # Apphosts such as Roslyn need this even when no shell activation runs.
    DOTNET_ROOT = "${config.xdg.dataHome}/mise/dotnet-root";
    # Lazy writes plugin pins to the checkout rather than the Nix store.
    NVIM_LOCKFILE = "${home}/.setup/config/nvim/lazy-lock.json";
    BROWSER = "vivaldi";
    JAVA_HOME = "/Applications/Android Studio.app/Contents/jbr/Contents/Home";
    TERMINAL = "ghostty";
  };
}
