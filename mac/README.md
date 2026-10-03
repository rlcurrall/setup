## Bootstrap (new machine)

One-liner — handles prerequisites then runs the installer:

```
curl -fsSL https://raw.githubusercontent.com/rlcurrall/setup/main/init-mac.sh | bash
```

You'll need to click "Install" on the Xcode dialog and type your password for `sudo` once or twice. Walk away during the Homebrew downloads.

If you'd rather run the steps yourself (e.g. for debugging):

1. Install Xcode Command Line Tools: `xcode-select --install`
2. Set the hostname to `helheim`:
   ```
   sudo scutil --set HostName helheim
   sudo scutil --set LocalHostName helheim
   sudo scutil --set ComputerName helheim
   ```
3. Clone the repo: `git clone https://github.com/rlcurrall/setup ~/.setup`
4. Run the installer: `bash ~/.setup/mac/install.sh`

## Post-bootstrap manual steps

The bootstrap can't do these — you must do them by hand:

- Create `~/.vars` with any secrets/env vars (the zsh init sources it if present). Example contents: API keys, `export FOO=bar`.
- Sign into 1Password (the GUI) to unlock SSH keys and secrets.
- Run `cd ~/Code && claude` once to sign in and accept the workspace trust prompt. The managed Claude Remote Control service will then start automatically at login and remain running.
- Authenticate the Datadog Pup CLI with `pup auth login`. If your Datadog site is not `datadoghq.com`, first add the appropriate `DD_SITE` export to `~/.vars` and restart your shell.
- Run `atuin login` then `atuin sync` to restore shell history.
- Open `nvim` once and wait for `:Lazy install` to pull plugins. Quit, reopen, run `:checkhealth` to confirm.
- Install the Android SDK packages after Android Studio and the command-line tools are present:
  ```
  android --no-metrics --sdk="$HOME/Library/Android/sdk" sdk install platform-tools
  android --no-metrics --sdk="$HOME/Library/Android/sdk" sdk install platforms/android-37.0
  android --no-metrics --sdk="$HOME/Library/Android/sdk" sdk install build-tools/36.0.0
  ```

## Known first-run quirks

- The very first `sudo` (during bootstrap) prompts for password — Touch ID for sudo isn't active until after the first rebuild applies it.
- nix-darwin sets the dock *before* the Homebrew bundle installs apps, so dock entries for `Ghostty`, `Discord`, etc. may be missing on the first activation. Run `rebuild` once more to fix.
- The first shell after install prints a harmless `compinit`/Docker completions warning until Docker Desktop is launched once.

## Day-to-day

- After editing `flake.nix`: run `rebuild` (alias defined in the flake). It runs `darwin-rebuild switch --flake .#helheim`.
- `:Lazy update` in nvim writes directly to `~/.setup/config/nvim/lazy-lock.json` (see `lockfile` option in `lazy.lua`), so updated plugin pins land in the dotfiles immediately — just `git add` + commit.
- To update nixpkgs/inputs themselves: `cd ~/.setup/mac && nix flake update`, then `rebuild`.

## Layout

- `flake.nix` — main nix-darwin + home-manager config (packages, Homebrew, dock, zsh, etc.)
- `install.sh` — first-time bootstrap script
- `../config/` — application configs (nvim, ghostty, starship, etc.) symlinked into `~/.config/` by home-manager
