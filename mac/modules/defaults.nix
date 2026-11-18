{ ... }:
{
  # GUI defaults
  system.defaults = {
    # Reduce/disable animations
    NSGlobalDomain.NSWindowResizeTime = 0.001;

    dock.autohide = true;
    dock.autohide-delay = 0.0;
    dock.autohide-time-modifier = 0.0;
    dock.launchanim = false;
    dock.mineffect = "scale";
    dock.expose-animation-duration = 0.12;
    dock.mru-spaces = false;
    dock.show-recents = false;
    dock.persistent-apps = [
      { app = "/Applications/Vivaldi.app"; }
    ];
    finder.AppleShowAllExtensions = true;
    finder.FXPreferredViewStyle = "clmv";
    screencapture.location = "~/Pictures/screenshots";
    screensaver.askForPasswordDelay = 10;

  };
}
