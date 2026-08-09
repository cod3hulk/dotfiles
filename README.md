# cod3hulk dotfiles

Personal dotfiles managed with [dotbot](https://github.com/anishathalye/dotbot), with an in-progress [chezmoi](https://www.chezmoi.io/) migration, and [Homebrew](https://brew.sh). Covers terminal, editor, window management, and shell tooling for macOS (with partial Linux support).

## Quick Start

Stable Dotbot installer:

```sh
git clone --recurse-submodules https://github.com/cod3hulk/dotfiles ~/.dotfiles
cd ~/.dotfiles
./install
```

Experimental chezmoi installer on the `chezmoi-migration` branch:

```sh
git switch chezmoi-migration
CHEZMOI_PROFILE=private-mac ./install-chezmoi
chezmoi diff --exclude scripts
chezmoi apply --exclude scripts
```

Supported chezmoi profiles: `private-mac`, `work-mac`, `linux-home`.

The Dotbot `install` script symlinks configs, installs Homebrew packages, and initializes plugins. The chezmoi migration currently manages symlinks in parallel; package installation is opt-in with `CHEZMOI_INSTALL_PACKAGES=1 chezmoi apply`.

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
| `tmux/` | tmux config — vi-mode, `C-a` prefix, Dracula theme, plugins via [tpm](https://github.com/tmux-plugins/tpm) (copycat, yank, navigator, **agent-indicator** for Claude Code state visualization with 🤖 icon and color-coded window tabs). See `tmux/AGENT_INDICATOR.md` for integration details. |

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

Dotbot links the following (see `install.conf.yaml` for the full list):

```
~/.zshrc                          → zsh/zshrc.zsh
~/.zprofile                       → zsh/zprofile.zsh
~/.config/nvim                    → nvim/
~/.tmux.conf                      → tmux/tmux.conf
~/.tmux/plugins/tpm               → tmux/tpm (git submodule)
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
```

## License

GPL v2
