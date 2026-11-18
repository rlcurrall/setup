{ pkgs, ... }:
{
  fonts.packages = [
    pkgs.fira-code
    pkgs.fira-code-symbols
    pkgs.nerd-fonts.fira-code
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.nerd-fonts.hack
  ];

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = [
    pkgs.zsh
    pkgs.git
    pkgs.jq
    pkgs.ripgrep
    pkgs.fzf
    pkgs.bat
    pkgs.fd
    pkgs.zellij
    pkgs.mise

    pkgs.uv
    pkgs.zig
    pkgs.rustup
    pkgs.just

    pkgs.btop
    pkgs.vim
    pkgs.neovim
    pkgs.tree-sitter
    pkgs.lazygit
    pkgs.lazydocker
    pkgs.ffmpeg

    pkgs.llama-cpp
  ];
}
