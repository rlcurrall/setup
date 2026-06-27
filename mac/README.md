## Bootstrap (new machine)

1. Install Xcode Command Line Tools: `xcode-select --install`
2. Set the hostname to `helheim`:
   ```
   sudo scutil --set HostName helheim
   sudo scutil --set LocalHostName helheim
   sudo scutil --set ComputerName helheim
   ```
3. Clone the repo: `git clone https://github.com/rlcurrall/setup ~/.setup`
4. Run the bootstrap: `bash ~/.setup/mac/install.sh`

## Post-bootstrap manual steps

The bootstrap can't do these — you must do them by hand:

- Create `~/.vars` with any secrets/env vars (the zsh init sources it if present). Example contents: API keys, `export FOO=bar`.
- Sign into 1Password (the GUI) to unlock SSH keys and secrets.
- Run `atuin login` then `atuin sync` to restore shell history.
- Open `nvim` once and wait for `:Lazy install` to pull plugins. Quit, reopen, run `:checkhealth` to confirm.

## Known first-run quirks

- The very first `sudo` (during bootstrap) prompts for password — Touch ID for sudo isn't active until after the first rebuild applies it.
- nix-darwin sets the dock *before* the Homebrew bundle installs apps, so dock entries for `Ghostty`, `Discord`, etc. may be missing on the first activation. Run `rebuild` once more to fix.
- The first shell after install prints a harmless `compinit`/Docker completions warning until Docker Desktop is launched once.

## Day-to-day

- After editing `flake.nix`: run `rebuild` (alias defined in the flake). It runs `darwin-rebuild switch --flake .#helheim`.
- After `:Lazy update` in nvim: run `lazysync` (alias defined in the flake) to copy the updated `lazy-lock.json` back into the dotfiles so future rebuilds pin to the same versions.
- To update nixpkgs/inputs themselves: `cd ~/.setup/mac && nix flake update`, then `rebuild`.

## Layout

- `flake.nix` — main nix-darwin + home-manager config (packages, Homebrew, dock, zsh, etc.)
- `install.sh` — first-time bootstrap script
- `../config/` — application configs (nvim, ghostty, starship, etc.) symlinked into `~/.config/` by home-manager
