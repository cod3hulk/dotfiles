# AGENT.md

This file provides guidance to AI coding agents when working with code in this repository.

## Installation

```sh
# Fresh install (clone + bootstrap)
git clone --recurse-submodules https://github.com/cod3hulk/dotfiles ~/.dotfiles
cd ~/.dotfiles
./install

# Re-run after changes to symlinks or shell init steps
./install
```

`./install` is the default chezmoi installer. It runs `install-chezmoi`, configures `~/.config/chezmoi/chezmoi.toml`, and applies the source state in `chezmoi/`.

Supported profiles: `private-mac`, `work-mac`, `linux-home`.

```sh
CHEZMOI_PROFILE=private-mac ./install
chezmoi diff
chezmoi apply
```

Package/bootstrap scripts are intentionally opt-in:

```sh
CHEZMOI_INSTALL_PACKAGES=1 chezmoi apply
```

Do not run package bootstrap unless explicitly requested; it can invoke Homebrew or apt.

Legacy Dotbot is still available via `./install-dotbot`. It uses `install.conf.yaml` to symlink configs and run the old shell hooks.

### Machine-Specific Overrides

- **zsh/zprofile.local.zsh** — machine-specific env vars (not tracked in git, sourced by `zsh/zprofile.zsh` if present)
- **alacritty/alacritty.local.toml** — machine-specific Alacritty overrides (not tracked)
- **tmux/*.backup** — automatic backups of configs before major changes (not tracked)

## Package Management

```sh
# Legacy Dotbot manifest
brew bundle install --file=brew/Brewfile

# Chezmoi split manifests
brew bundle install --file=brew/Brewfile.common
brew bundle install --file=brew/Brewfile.private-mac
brew bundle install --file=brew/Brewfile.work-mac
```

`brew/Brewfile` remains the Dotbot manifest. The split `Brewfile.*` files are used by chezmoi package bootstrap.

## Architecture

### Symlink Management (chezmoi)

All config files live in this repo and are symlinked into place by chezmoi source-state entries under `chezmoi/`. Adding a new managed link means: (1) create its config directory here, (2) add a `symlink_*` entry under `chezmoi/`, (3) update `.chezmoiignore.tmpl` for OS/profile-specific applicability.

Legacy Dotbot mapping remains in `install.conf.yaml` for `./install-dotbot`, but chezmoi is the default installer.

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

### Pi Coding Agent

Pi config lives under `pi/` and is installed by Dotbot or linked by chezmoi.

Install/apply profiles:

```sh
# Private machine: includes pi-mcp-adapter and private MCP setup
CHEZMOI_PROFILE=private-mac ./install

# Work machine: excludes private MCP
CHEZMOI_PROFILE=work-mac ./install

# Linux/shared machine: common Pi profile
CHEZMOI_PROFILE=linux-home ./install
```

Package installation/update is opt-in with `CHEZMOI_INSTALL_PACKAGES=1 chezmoi apply`. Legacy Dotbot can still run `pi/scripts/apply-profile.sh "$PI_PROFILE"` via `./install-dotbot`.

Important files:

- `pi/config/settings.common.json` — shared profile without MCP
- `pi/config/settings.work.json` — work profile without private MCP
- `pi/config/settings.private.json` — private profile with `npm:pi-mcp-adapter`
- `pi/config/rtk-optimizer.json` — shared `pi-rtk-optimizer` config, exposed via `pi/extensions/pi-rtk-optimizer/config.json`
- `pi/packages/base/` — shared Pi package for portable extensions/skills/prompts/themes
- `pi/mcp/private.mcp.example.json` — private MCP template using environment-variable secrets
- `pi/AGENT.md` — detailed Pi-specific agent notes

Chezmoi links:

- `~/.hermes/skins/dracula.yaml` -> `hermes/skins/dracula.yaml`; a chezmoi onchange script activates it with `hermes config set display.skin dracula` when Hermes is installed
- `~/.pi/agent/settings.json` -> profile-specific `pi/config/settings.*.json`
- `~/.pi/agent/extensions` -> `pi/extensions`
- `~/.pi/agent/themes` -> `pi/themes`
- `~/.pi/agent/mcp.json` -> `~/.config/mcp/mcp.json` on `private-mac` only

Never commit real MCP/API tokens. Keep `~/.pi/agent/auth.json`, `sessions/`, `trust.json`, `npm/`, `git/`, and `mcp-cache.json` local.

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
