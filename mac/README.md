## Bootstrap (new machine)

One-liner — handles prerequisites then runs the installer:

```
curl -fsSL https://raw.githubusercontent.com/rlcurrall/setup/main/init-mac.sh | bash
```

You'll need to click "Install" on the Xcode dialog and type your password for `sudo` once or twice. Walk away during the Homebrew downloads.

If you'd rather run the steps yourself (e.g. for debugging):

1. Install Xcode Command Line Tools: `xcode-select --install`
2. Clone the repo: `git clone https://github.com/rlcurrall/setup ~/.setup`
3. Run the installer: `bash ~/.setup/mac/install.sh personal` or `bash ~/.setup/mac/install.sh work`.

The installer selects `personal` automatically for `robb` and `work` for `robcurrall` when no argument is supplied. An explicit profile must match the current account. Hostnames are left unchanged.

## Machine profiles

- `personal` uses `/Users/robb` and `mac/profiles/personal.nix`.
- `work` uses `/Users/robcurrall` and `mac/profiles/work.nix`.
- `flake.nix` assembles the machines. Shared system settings live in `modules/`; shared user settings live in `home/`. Add machine-specific packages and overrides to the corresponding profile module. Home Manager overrides go under `home-manager.users.robb` or `home-manager.users.robcurrall`.
- ChatGPT, Discord, Minecraft, OBS, Steam, and the GitLab CLI (`glab`) are personal-only. Azure tools (Azure CLI, Azure Developer CLI, and Azure Functions Core Tools), Databricks, Datadog Pup, Granola, and New Relic CLI are work-only. Beads is no longer managed. Removing a package from a profile does not uninstall an existing copy: Homebrew cleanup remains disabled.
- `helheim` remains an alias for `personal` so the existing rebuild command continues to work.

To select a profile on an existing installation:

```sh
bash ~/.setup/mac/rebuild.sh personal # or work
```

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

## Day-to-day

- After editing `flake.nix`: run `rebuild` (alias defined in the flake). It runs `rebuild.sh` with the selected `personal` or `work` profile, building as your user before using `sudo` to select and activate the system generation. This avoids Git ownership errors from evaluating the checkout as root.
- Rex keybindings and actions live in `../config/rex/init.lua`, linked to `~/.config/rex/init.lua` by Home Manager for both Mac profiles. Edit the repository copy and run `rebuild` to apply changes.
- Home Manager sets `NVIM_LOCKFILE` to `~/.setup/config/nvim/lazy-lock.json`, so `:Lazy update` writes plugin pins into the checkout for committing. Run `rebuild` and start a new shell after changing session variables. Standalone Neovim configs use their own lockfile; read-only deployments fall back to a writable copy in Neovim’s data directory.
- Homebrew refreshes itself and package metadata before certain manually invoked Brew commands. There is no scheduled package-upgrade job in this setup. Rebuild activation explicitly disables Brew auto-update, upgrades, and cleanup. Run `brew update` followed by `brew upgrade` when you want to upgrade installed Brew packages; applications may also have their own updaters.
- Mise installs missing configured tools after Home Manager links the new configuration. Developer-tool requests remain `latest`; .NET follows the latest releases within majors 8 and 10. Use `mise upgrade` for deliberate developer-tool upgrades.
- To update nixpkgs/inputs themselves: `cd ~/.setup/mac && nix flake update`, then `rebuild`.

## Nix garbage collection

Both profiles schedule garbage collection for Sunday at 03:15 local time,
retiring old profile generations with `--delete-older-than 30d` before collecting
unreferenced store paths. The active generation remains protected. A deleted
generation is no longer available for immediate rollback; its Git configuration
can still be rebuilt if its sources and dependencies remain available.

The job does not run when the configuration is activated. If the Mac is asleep
at the scheduled time, launchd runs it when the Mac wakes. Homebrew packages,
Mise SDK installations, projects, and personal files are outside this cleanup.
Explicit build-result links can retain store paths beyond the generation
retention window; remove temporary verification links when they are no longer
needed.

Check the loaded job with `launchctl print system/org.nixos.nix-gc`. To inspect
currently unreferenced paths without deleting them, use
`nix-store --gc --print-dead`. This preview does not retire old generations.

## .NET SDKs and runtimes

Mise owns the development SDKs. The global configuration requests SDK majors
10 and 8, keeping both runtime families available while .NET 8 projects migrate.
Other developer-tool requests remain `latest`.

PowerShell's Homebrew formula requires Brew's `dotnet` package (currently .NET
11). Retain that dependency: PowerShell's launcher selects its own Brew runtime,
while development shells select Mise's SDKs. It is not a development SDK request
in this configuration. The old standalone `dotnet-sdk` cask and `dotnet@8`
formula are unnecessary once Mise has been verified.

SDKs share `~/.local/share/mise/dotnet-root`. Home Manager sets `DOTNET_ROOT`
for apphosts such as Roslyn and adds Mise shims to the session PATH, including
non-interactive shells. The managed Claude service receives the same runtime
root and shim path. Start a new shell after rebuilding to load these changes.

Mise reads project `global.json` SDK requests. .NET applies the file's native
SDK selection and roll-forward rules; without `global.json`, the newest
installed SDK is selected. Use `mise install` in a project to install its
requested SDK if it is missing. A project needing an exact older SDK must
request that exact version even when another release of the same major exists.

```sh
dotnet --list-sdks
dotnet --list-runtimes
mise upgrade dotnet
```

Upgrades stay within the configured 8/10 requests. When the migration is
complete, remove the `"8"` request and explicitly uninstall the unneeded SDKs
and runtimes. Removing a request alone does not delete installed versions.
On another existing Mac, rebuild and verify Mise first, then explicitly remove
the old `dotnet-sdk` cask and `dotnet@8` formula if present. Keep Brew's `dotnet`
while PowerShell depends on it; do not force its removal with
`--ignore-dependencies`. Global Brew cleanup remains disabled.

## Layout

- `flake.nix` — inputs, machine assembly, and evaluation checks for both profiles
- `modules/system.nix` — Nix, platform, users, system shell, and compatibility settings
- `modules/packages.nix` — Nix packages and fonts
- `modules/homebrew.nix` — shared Brew packages, casks, taps, and activation policy
- `modules/defaults.nix` — macOS preferences
- `home/` — user files, environment, shell, services, and Mise installation
- `profiles/` — personal and work overrides
- `install.sh` — first-time bootstrap script
- `rebuild.sh` — builds and activates the selected Mac profile
- `../config/` — application configs (nvim, ghostty, starship, etc.) symlinked into `~/.config/` by home-manager

## Verification

From the repository root, evaluate both complete system configurations without
building or activating them:

```sh
nix flake check ./mac --no-build
bash -n init-mac.sh mac/install.sh mac/rebuild.sh
```

Completion directories are added before Oh My Zsh runs `compinit`; no second
completion initialization is needed. Docker completions are added only when
the directory exists. Work retains its pre-generated prompt/history/navigation
scripts to avoid repeated process scans during shell startup.
