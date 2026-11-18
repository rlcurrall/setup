{ config, home, me, ... }:
{
  # Keep Claude Remote Control available for sessions started from
  # claude.ai/code or the Claude mobile app.
  launchd.agents.claude-remote-control = {
    enable = true;
    config = {
      ProgramArguments = [
        "/opt/homebrew/bin/claude"
        "remote-control"
      ];
      WorkingDirectory = "${home}/Code";
      EnvironmentVariables = {
        HOME = home;
        DOTNET_ROOT = config.home.sessionVariables.DOTNET_ROOT;
        PATH = "${config.xdg.dataHome}/mise/shims:/opt/homebrew/bin:/opt/homebrew/sbin:${home}/.local/bin:${home}/.bin:/etc/profiles/per-user/${me}/bin:/run/current-system/sw/bin:/usr/bin:/bin:/usr/sbin:/sbin";
      };
      RunAtLoad = true;
      KeepAlive = true;
      ThrottleInterval = 10;
      ProcessType = "Background";
      StandardOutPath = "${home}/Library/Logs/claude-remote-control.log";
      StandardErrorPath = "${home}/Library/Logs/claude-remote-control.error.log";
    };
  };
}
