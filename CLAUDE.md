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

`./install` is the default [chezmoi](https://www.chezmoi.io/) installer. It runs `install-chezmoi`, configures `~/.config/chezmoi/chezmoi.toml`, and applies the source state in `chezmoi/`.

Package/bootstrap scripts are selected by OS (`brew` on macOS, `apt`/upstream releases on Linux). Profile selection uses hostname: `cod3hulk` selects the private profile automatically; other hostnames prompt once and persist the choice. Override with `CHEZMOI_PROFILE=...` if needed.

```sh
CHEZMOI_PROFILE=work-mac ./install
```

Package/bootstrap scripts are opt-in:

```sh
CHEZMOI_INSTALL_PACKAGES=1 ./install
```

### Machine-Specific Overrides

- **zsh/zprofile.local.zsh** — machine-specific env vars (not tracked in git, sourced by `zsh/zprofile.zsh` if present)
- **alacritty/alacritty.local.toml** — machine-specific Alacritty overrides (not tracked)
- **tmux/*.backup** — automatic backups of configs before major changes (not tracked)

## Package Management

```sh
brew bundle install --file=brew/Brewfile.common
brew bundle install --file=brew/Brewfile.private-mac
brew bundle install --file=brew/Brewfile.work-mac
```

## Architecture

### Symlink Management (chezmoi)

Most config files live in this repo and are symlinked into place by chezmoi source-state entries under `chezmoi/`. Adding a new managed link means: (1) create its config directory here, (2) add a `symlink_*` entry under `chezmoi/`, (3) update `.chezmoiignore.tmpl` for OS/profile-specific applicability. Mutable runtime configs, such as Pi settings, should use `create_*` seeds instead of symlinks so local app changes do not dirty git.

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

Config at `tmux/tmux.conf`. Prefix is `C-a`. TPM itself is managed by chezmoi external resources for new installs. Key plugins:
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
| `hammerspoon/` | macOS automation config |
| `tmux/tpm` | Tmux plugin manager source snapshot retained for compatibility/reference; chezmoi installs TPM as an external resource |
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
