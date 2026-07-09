# Ubuntu Setup - Mac-Aligned Nix Configuration

This Ubuntu setup mirrors your Mac configuration structure while incorporating useful Omakub features like fixed workspaces and better GNOME integration.

## Philosophy

This setup aligns your Ubuntu environment with your Mac setup while adding Linux-specific enhancements:

- **Consistency**: Matches your Mac setup (zsh, Ghostty, same apps)
- **Enhanced**: Adds useful Omakub features (fixed workspaces, better dock)
- **Practical**: System packages via apt, GUI apps via Flatpak, dotfiles via Nix
- **Familiar**: Same tools and workflow as your Mac

## What's Managed Where

### Nix Home Manager (`home.nix`, `apps.nix`, `gnome.nix`)
- Dotfiles (nvim, btop, lazygit, ghostty, mise, zellij)
- CLI tools (matching Mac setup: git, ripgrep, fzf, bat, etc.)
- Shell configuration (zsh with Oh My Zsh, starship, atuin, zoxide)
- GNOME settings and keybindings
- GUI apps via Flatpak (matching Mac cask approach)

### System Setup (`system-setup.sh`)
- System libraries and development tools
- Docker, VSCode, 1Password
- Azure Functions Core Tools, Pulumi
- GNOME extensions

## Key Features

1. **Shell**: zsh with Oh My Zsh (matching Mac)
2. **Terminal**: Ghostty (matching Mac)
3. **Extensions**: Essential + useful (just-perfection, blur-my-shell, undecorate, dash-to-dock, space-bar)
4. **Apps**: Same as Mac dock (Ghostty, 1Password, Claude, etc.)
5. **Workspaces**: Fixed 6 workspaces (Omakub feature)
6. **Fonts**: Same Nerd Fonts as Mac

## Installation

Run the install script:

```bash
curl -fsSL https://raw.githubusercontent.com/rlcurrall/setup/main/ubuntu/install.sh | bash
```

Or manually:

```bash
git clone https://github.com/rlcurrall/setup.git ~/.setup
cd ~/.setup/ubuntu
./install.sh
```

## Making Changes

- **Dotfiles**: Edit files in `../config/` and run `rebuild`
- **Nix packages**: Edit `apps.nix` and run `rebuild`
- **GNOME settings**: Edit `gnome.nix` and run `rebuild`
- **System packages**: Edit `system-setup.sh` and re-run it

## Rebuild Command

After making changes to Nix configuration:

```bash
rebuild
```

This is an alias for `home-manager switch --flake ~/.setup/ubuntu#robb`.

## Restoring Your Original Setup

If you want to go back to your original bash-based setup, your `setup.sh` is preserved and can be run independently of this Nix configuration.