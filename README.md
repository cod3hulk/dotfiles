# cod3hulk dotfiles

Personal dotfiles managed with [chezmoi](https://www.chezmoi.io/) and [Homebrew](https://brew.sh), with the previous [dotbot](https://github.com/anishathalye/dotbot) installer kept as legacy. Covers terminal, editor, window management, and shell tooling for macOS (with partial Linux support).

## Quick Start

Default chezmoi installer:

```sh
git clone --recurse-submodules https://github.com/cod3hulk/dotfiles ~/.dotfiles
cd ~/.dotfiles
./install
```

Package/bootstrap scripts are selected by OS (`brew` on macOS, `apt`/upstream releases on Linux). Profile selection uses hostname: `cod3hulk` selects the private profile automatically; other hostnames prompt once and persist the choice. Override with `CHEZMOI_PROFILE=...` if needed.

`./install` configures chezmoi and applies managed links. Chezmoi also downloads external dotfile dependencies such as zgen, TPM, and Linux fzf. Package installation is opt-in:

```sh
CHEZMOI_INSTALL_PACKAGES=1 chezmoi apply
```

Legacy Dotbot installer:

```sh
./install-dotbot
```

## What's Inside

### Shell

| Directory | Description |
|-----------|-------------|
| `zsh/` | Zsh config using [zgen](https://github.com/tarjoilija/zgen) + zprezto — autocomplete, syntax highlighting, autosuggestions |
| `alias/` | Aliases for `nvim`, `git`, `docker`, `kubectl`, `mvn`, and file search helpers |
| `function/` | Custom functions: terminal color display, IntelliJ project opener, Docker helpers |
| `autojump/` | [autojump](https://github.com/wting/autojump) integration (platform-aware) |
| `fzf/` | Fuzzy finder shell integration with interactive `cd` and search |

### Editor

| Directory | Description |
|-----------|-------------|
| `nvim/` | Neovim config — [lazy.nvim](https://github.com/folke/lazy.nvim) plugin manager, LSP, Treesitter, [which-key](https://github.com/folke/which-key.nvim), [gitsigns](https://github.com/lewis6991/gitsigns.nvim), [flash.nvim](https://github.com/folke/flash.nvim), [claude-code.nvim](https://github.com/pasky/claude-code.nvim) for in-editor Claude sessions |
| `intellij/` | IdeaVim config (`.ideavimrc`) for Vim keybindings in IntelliJ |
| `vscode/` | VS Code `settings.json` and `keybindings.json` |

### Terminal Emulators

| Directory | Description |
|-----------|-------------|
| `alacritty/` | GPU-accelerated terminal — keybindings, colors, display (TOML + YAML) |
| `kitty/` | Terminal with split layouts, nvim scrollback integration, remote control |

### macOS Window Management

| Directory | Description |
|-----------|-------------|
| `yabai/` | Tiling window manager — BSP layout, window focus/opacity, mouse interaction |
| `skhd/` | Hotkey daemon — `Alt`-key combos for yabai window navigation and manipulation |
| `hammerspoon/` | Lua automation — Spoons for app switching, media controls, vim-like bindings |
| `borders/` | Window border decorations ([JankyBorders](https://github.com/FelixKratz/JankyBorders)) with Dracula active/inactive colors |
| `limelight/` | Window highlighter config (Dracula pink active window border) |

### Keyboard Remapping

| Directory | Description |
|-----------|-------------|
| `karabiner/` | macOS keyboard remapper — `caps_lock→control`, tab mod-tap (tap=tab, hold=hyper) |
| `kanata/` | Cross-platform key remapping tool config (backup files only, not currently active) |

### Multiplexer

| Directory | Description |
|-----------|-------------|
| `tmux/` | tmux config — vi-mode, `C-a` prefix, Dracula theme, plugins via [tpm](https://github.com/tmux-plugins/tpm) (managed by chezmoi external resources for new installs; legacy submodule kept for Dotbot compatibility). Includes copycat, yank, navigator, **agent-indicator** for Claude Code state visualization with 🤖 icon and color-coded window tabs. See `tmux/AGENT_INDICATOR.md` for integration details. |

### CLI Tools & Packages

| Directory | Description |
|-----------|-------------|
| `brew/` | Homebrew manifests — legacy `Brewfile` for Dotbot plus split `Brewfile.common`, `Brewfile.private-mac`, `Brewfile.work-mac` for chezmoi profiles |
| `k8s/` | Kubernetes utilities — `kubectx` (context switcher), `kubens` (namespace switcher), kubectl plugins |
| `k9s/` | Kubernetes dashboard config with Dracula theme |
| `tig/` | [tig](https://jonas.github.io/tig/) (text-mode git UI) config |
| `scripts/` | Automation scripts (includes Spotify control) |

### Other

| Directory | Description |
|-----------|-------------|
| `dracula/` | Dracula theme assets shared across tools |
| `linux/` | Linux-specific initialization |
| `colima/` | [Colima](https://github.com/abiosoft/colima) (Docker on macOS) config |

## Recent Updates

- **tmux-agent-indicator** — Visual feedback for Claude Code agent states (running/needs-input/done)
- **claude-code.nvim** — In-editor Claude Code integration for Neovim
- **Alacritty** — Disabled `alt_send_esc` for proper Alt key handling in macOS
- **Neovim** — Removed Comment.nvim plugin in favor of built-in commenting (gc operator)
- **tmux** — Enabled passthrough mode for better terminal compatibility
- **Go toolchain** — Added to Brewfile with environment setup
- **Local configs** — Support for machine-specific overrides (`.local.*` files, git-ignored)

## Symlinks Created

Chezmoi links the following (see `chezmoi/AUDIT.md` for the full list and profile/OS conditions):

```
~/.zshrc                          → zsh/zshrc.zsh
~/.zprofile                       → zsh/zprofile.zsh
~/.config/nvim                    → nvim/
~/.tmux.conf                      → tmux/tmux.conf
~/.tmux/plugins/tpm               → external tmux-plugins/tpm archive
~/.tmux/scripts                   → tmux/scripts
~/.yabairc                        → yabai/yabairc
~/.limelight                      → limelight/limelight.sh
~/.skhdrc                         → skhd/skhdrc
~/.hammerspoon                    → hammerspoon/
~/.config/alacritty/              → alacritty/
~/.config/kitty/                  → kitty/
~/.config/karabiner/              → karabiner/ (force)
~/.config/borders/bordersrc       → borders/bordersrc
~/.config/i3/config               → i3/config
~/.config/Code/User/settings.json → vscode/settings.json
~/.config/Code/User/keybindings.json → vscode/keybindings.json
~/.ideavimrc                      → intellij/ideavimrc
~/.tigrc                          → tig/tig.conf
~/.pi/agent/settings.json          → pi/config/settings.*.json
~/.pi/agent/extensions             → pi/extensions/
~/.pi/agent/themes                 → pi/themes/
```

## License

GPL v2
