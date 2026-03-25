# cod3hulk dotfiles

Personal dotfiles managed with [dotbot](https://github.com/anishathalye/dotbot) and [Homebrew](https://brew.sh). Covers terminal, editor, window management, and shell tooling for macOS (with partial Linux support).

## Quick Start

```sh
git clone --recurse-submodules https://github.com/cod3hulk/dotfiles ~/.dotfiles
cd ~/.dotfiles
./install
```

The `install` script runs dotbot, which symlinks configs, installs Homebrew packages, and initializes plugins.

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
| `nvim/` | Neovim config — [lazy.nvim](https://github.com/folke/lazy.nvim) plugin manager, LSP, Treesitter, [which-key](https://github.com/folke/which-key.nvim), [gitsigns](https://github.com/lewis6991/gitsigns.nvim), [flash.nvim](https://github.com/folke/flash.nvim) |
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

### Keyboard Remapping

| Directory | Description |
|-----------|-------------|
| `karabiner/` | macOS keyboard remapper — `caps_lock→control`, tab mod-tap (tap=tab, hold=hyper) |
| `kanata/` | Cross-platform key remapping tool config |

### Multiplexer

| Directory | Description |
|-----------|-------------|
| `tmux/` | tmux config — vi-mode, `C-a` prefix, Dracula theme, plugins via [tpm](https://github.com/tmux-plugins/tpm) (copycat, yank, navigator) |

### CLI Tools & Packages

| Directory | Description |
|-----------|-------------|
| `brew/` | Homebrew manifest — dev tools (`git`, `neovim`, `tmux`, `ripgrep`, `jq`, `fzf`, `kubectl`) and macOS apps |
| `k9s/` | Kubernetes dashboard config with Dracula theme |
| `tig/` | [tig](https://jonas.github.io/tig/) (text-mode git UI) config |
| `scripts/` | Automation scripts (includes Spotify control) |

### Other

| Directory | Description |
|-----------|-------------|
| `dracula/` | Dracula theme assets shared across tools |
| `linux/` | Linux-specific initialization |
| `colima/` | [Colima](https://github.com/abiosoft/colima) (Docker on macOS) config |

## Symlinks Created

Dotbot links the following (see `install.conf.yaml` for the full list):

```
~/.zshrc                          → zsh/zshrc.zsh
~/.zprofile                       → zsh/zprofile.zsh
~/.config/nvim                    → nvim/
~/.tmux.conf                      → tmux/tmux.conf
~/.yabairc                        → yabai/yabairc
~/.skhdrc                         → skhd/skhdrc
~/.hammerspoon                    → hammerspoon/
~/.config/alacritty/              → alacritty/
~/.config/kitty/                  → kitty/
~/.config/kanata/kanata.kbd       → kanata/kanata.kbd
~/.config/karabiner/              → karabiner/
~/.config/borders/bordersrc       → borders/bordersrc
~/.config/i3/config               → i3/config
~/.config/Code/User/settings.json → vscode/settings.json
~/.ideavimrc                      → intellij/ideavimrc
~/.tigrc                          → tig/tig.conf
```

## License

GPL v2
