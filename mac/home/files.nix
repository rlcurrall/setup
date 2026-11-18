{ ... }:
{
  home.file = {
    # Create Code directory
    "Code/.keep".text = "";
  };

  xdg.configFile = {
    "nvim" = {
      source = ../../config/nvim;
      recursive = true;
    };

    "btop" = {
      source = ../../config/btop;
      recursive = true;
    };

    "lazygit" = {
      source = ../../config/lazygit;
      recursive = true;
    };

    "ghostty" = {
      source = ../../config/ghostty;
      recursive = true;
    };

    "rex" = {
      source = ../../config/rex;
      recursive = true;
    };

    "mise" = {
      source = ../../config/mise;
      recursive = true;
    };

    "zellij" = {
      source = ../../config/zellij;
      recursive = true;
    };
    "starship.toml" = {
      source = ../../config/starship.toml;
    };
  };
}
