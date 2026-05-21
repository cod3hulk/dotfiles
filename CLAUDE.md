# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Installation

```sh
# Fresh install (clone + bootstrap)
git clone --recurse-submodules https://github.com/cod3hulk/dotfiles ~/.dotfiles
cd ~/.dotfiles
./install

# Re-run after changes to symlinks or shell init steps
./install
```

`./install` runs [dotbot](https://github.com/anishathalye/dotbot) using `install.conf.yaml`, which:
1. Cleans broken symlinks in `~` and `~/.config`
2. Creates symlinks for all configs
3. Runs `brew/init.zsh`, `linux/init.zsh`, `zgen/init.zsh` as post-install hooks
4. Creates `~/.hushlogin` to suppress login messages

### Machine-Specific Overrides

- **zsh/zprofile.local.zsh** — machine-specific env vars (not tracked in git, sourced by `zsh/zprofile.zsh` if present)
- **alacritty/alacritty.local.toml** — machine-specific Alacritty overrides (not tracked)
- **tmux/*.backup** — automatic backups of configs before major changes (not tracked)

## Package Management

```sh
# Install all packages from manifest
brew bundle install --file=brew/Brewfile

# Add a new package (edit Brewfile, then install)
brew bundle install --file=brew/Brewfile
```

## Architecture

### Symlink Management (Dotbot)

All config files live in this repo and are symlinked into place by dotbot. The authoritative mapping is `install.conf.yaml`. Adding a new tool means: (1) create its config directory here, (2) add a `link:` entry to `install.conf.yaml`, (3) optionally add an `init.zsh`/`init.sh` script and reference it in the `shell:` section.

### Shell (Zsh)

- Entry point: `zsh/zshrc.zsh` — loads zgen, zprezto plugins, then sources `alias/alias.zsh`, `fzf/fzf.zsh`, `autojump/autojump.zsh`, `function/function.zsh`
- Login shell: `zsh/zprofile.zsh` — sets PATH, EDITOR, Homebrew env
- Aliases live in `alias/alias.zsh`; functions in `function/function.zsh`

### Neovim

- Entry point: `nvim/init.lua` — requires all modules under `nvim/lua/user/`
- Plugin manager: [lazy.nvim](https://github.com/folke/lazy.nvim) (auto-installs on first launch)
- Key modules: `plugins.lua` (all plugin specs), `which-key.lua` (keybinding palette), `lsp/` (language server setup), `conform.lua` (formatting)
- Notable plugins:
  - **claude-code.nvim** — in-editor Claude Code sessions
  - Built-in commenting (removed Comment.nvim in favor of native vim commenting)
  - flash.nvim for motion navigation
  - vim-tmux-navigator for seamless tmux integration

### macOS Window Management

- **yabai** (`yabai/yabairc`) — tiling WM, BSP layout, started via `yabai/init.sh`
- **skhd** (`skhd/skhdrc`) — hotkey daemon for yabai control (Alt+hjkl navigation), started via `skhd/init.sh`
- **hammerspoon** (`hammerspoon/`) — Lua automation, git submodule pointing to `https://github.com/cod3hulk/hammerspoon-config.git`
- **borders** (`borders/bordersrc`) — JankyBorders window decorations, started via `borders/init.sh`

### Tmux

Config at `tmux/tmux.conf`. Prefix is `C-a`. Plugins managed by [tpm](https://github.com/tmux-plugins/tpm) (git submodule at `tmux/tpm`). Key plugins:
- **tmux-resurrect** — session save/restore
- **tmux-continuum** — auto-save every 10 min
- **vim-tmux-navigator** — seamless vim/tmux pane navigation
- **tmux-agent-indicator** — Claude Code agent state visualization (see `tmux/AGENT_INDICATOR.md`)
  - Shows 🤖 in status bar when Claude agent is active
  - Window tabs change color: 🟠 orange (running), 🔴 red (needs input), 🟢 green (done)
  - Hooks configured in `~/.claude/settings.json` for automatic state updates
  - Passthrough mode enabled for better compatibility

### Git Submodules

| Submodule | Purpose |
|-----------|---------|
| `dotbot/` | Installation framework |
| `hammerspoon/` | macOS automation config |
| `tmux/tpm` | Tmux plugin manager |
| `dracula/iterm`, `dracula/alfred` | Theme assets |

When adding a new submodule: `git submodule add <url> <path>` and re-run `./install`.

### Keyboard Remapping

- **karabiner** (`karabiner/`) — macOS only; `caps_lock→control`, tab mod-tap. Symlinked with `force: true` because Karabiner manages its own directory.
- **kanata** (`kanata/kanata.kbd`) — cross-platform alternative

### Kubernetes Tools

- **k8s/** directory contains kubectl plugins:
  - `kubectx` — quickly switch between Kubernetes contexts
  - `kubens` — quickly switch between Kubernetes namespaces
  - `kubectl/` — kubectl completion and aliases
- k9s config with Dracula theme at `k9s/`

### Dracula Theme

Dracula is the unified theme across all tools (nvim colorscheme, tmux status bar (including tmux-agent-indicator window tabs), borders colors, k9s, terminal emulators). When adding a new tool, look for its Dracula theme variant first.
