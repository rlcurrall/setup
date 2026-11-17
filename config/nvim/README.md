# Neovim configuration

The source lives in `~/.setup/config/nvim`. Nix Home Manager normally installs
these files under `~/.config/nvim`. Lazy writes plugin pins to the source
`lazy-lock.json`, which should be committed with configuration changes.

## Components

- Completion: Blink 1.x, Neovim's native snippet engine, Friendly Snippets.
- C#: Roslyn, with project/solution selection and generated-source navigation.
- JavaScript/TypeScript: `ts_ls` through Neovim's LSP client.
- Formatting: Conform with CSharpier, StyLua, and oxfmt.
- Editing: Mini pairs, text objects, surroundings, comment-tag highlighting,
  statusline, and icons. Mini provides compatibility for devicons consumers.
- Navigation/UI: Snacks, Trouble, Noice/Nui, WhichKey, and Auto Session.
- LSP references: Snacks Words. LSP progress: Fidget.
- Debugging: nvim-dap and DAP UI, NetCoreDbg for C#, Microsoft's JavaScript
  debug adapter for Node/TypeScript. No Go debugger is configured.

## Terminal colors

osc-colors derives editor colors from the host terminal's palette. It queries
colors at startup and on focus regain; use `:OscColorsRefresh` after changing
a terminal theme if focus did not change. The editor background is transparent
so the terminal draws its own background, including Rex's glass material.
Popups use an opaque terminal-derived background for readability. The generated
keyword color accents the normal-mode statusline, borders, and completion
selection. Other mode colors and diagnostic severity colors stay distinct;
diagnostics use undercurls. Noice, Snacks, diagnostics, and Mini statusline use
the resulting colors. This approximates a theme from its terminal
palette rather than loading the theme's official Neovim port.

Rosé Pine provides the initial colors before cached/live terminal colors apply.
The system light/dark switcher is inactive while terminal colors are enabled.
For the Rosé Pine light/dark fallback, launch `NVIM_THEME=rose-pine nvim`.
The plugin is experimental; Rex palette detection and refresh are verified.

## Indentation and whitespace

Neovim's built-in EditorConfig support owns project indentation and trailing
whitespace rules. Without a project rule, the defaults are four spaces, with
two-space fallbacks for Lua and web filetypes. Sleuth and the project-module
indentation overrides are removed. Project build/run/test keybindings remain.
Markdown trailing spaces are preserved when `.editorconfig` opts out of trimming.

## Tools

Neovim 0.12+, Git, ripgrep, a C compiler, the tree-sitter CLI, Node/npm,
and the .NET SDK are required for the configured languages and parsers.
A Nerd Font is used for icons. Mason manages language tools and the JavaScript
debug adapter. oxfmt is available through Mise or a project's `node_modules`.

Roslyn and NetCoreDbg are pinned in `scripts/tool-versions.json`. The installers
support Apple Silicon macOS, Linux x64/ARM64, and Windows x64. Neovim chooses the
shell or PowerShell installer and the correct executable path automatically.
The tools live under Neovim's data directory, outside project SDKs/dependencies.

Roslyn is checked during startup. NetCoreDbg is checked when the debugger is
first loaded; Lazy also installs tools during plugin installation/builds. A
missing executable or a version stamp that differs from the configured pin
triggers installation. Matching stamps skip the installer, so ordinary boots
perform no tool-download or latest-release checks.

Upgrades are deliberate: update the version pin, then restart Neovim/load the
debugger, or install the configured versions immediately on any platform:

```vim
:lua require('custom.tools').install('roslyn')
:lua require('custom.tools').install('debugger')
```

From a terminal, use `sh ~/.config/nvim/scripts/install-tools.sh all` on Unix,
or run `install-tools.ps1 all` from the configuration's `scripts` folder in
Windows PowerShell. The installers require the .NET SDK and network access
when a tool must be installed. PowerShell installations do not require symlink
privileges or Windows Developer Mode.

## Keys

- Completion: `Ctrl-Space` opens the menu; `Ctrl-n`/`Ctrl-p` select;
  `Ctrl-y` accepts. `Ctrl-l`/`Ctrl-h` move through snippet placeholders.
- Debugging: `F5` starts/continues; `F1`/`F2`/`F3` step into/over/out;
  `<leader>db` toggles a breakpoint; `<leader>dB` sets a conditional breakpoint;
  `F7` toggles the debugger UI.
- C# launch prompts for an application DLL. Node launch pauses at entry;
  press `F5` again to continue. Both languages have process-attach options.
- Project build/run/test shortcuts use the nearest project directory, including
  nested Node packages and standalone C# projects/solutions (`.csproj`, `.sln`,
  `.slnx`). Commands restore Neovim's working-directory scope afterwards.
- `<leader>th` toggles inlay hints only in the current buffer. C# hints start
  enabled when a supporting LSP attaches; your choice survives buffer switches
  and LSP reattachments. `<leader>tj` toggles diagnostic virtual lines separately.
- Project-specific npm, tsx, or other launch commands belong in
  `.vscode/launch.json`, which nvim-dap reads automatically. Compiled TypeScript
  needs source maps to bind breakpoints in the original `.ts` files.

Use `:Lazy`, `:Mason`, `:ConformInfo`, `:LspInfo`, and `:checkhealth` to inspect
plugin versions, tools, formatters, and language-server status.
