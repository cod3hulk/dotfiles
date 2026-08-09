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

`./install` runs [dotbot](https://github.com/anishathalye/dotbot) using `install.conf.yaml`, which:
1. Cleans broken symlinks in `~` and `~/.config`
2. Creates symlinks for all configs
3. Runs `brew/init.zsh`, `linux/init.zsh`, `zgen/init.zsh` as post-install hooks
4. Creates `~/.hushlogin` to suppress login messages

### Chezmoi Migration

The `chezmoi-migration` branch contains an in-progress chezmoi migration in `chezmoi/` plus `install-chezmoi`.

Safe test/apply flow:

```sh
CHEZMOI_PROFILE=private-mac ./install-chezmoi
chezmoi diff --exclude scripts
chezmoi apply --exclude scripts
```

Supported profiles: `private-mac`, `work-mac`, `linux-home`.

Package/bootstrap scripts are intentionally opt-in:

```sh
CHEZMOI_INSTALL_PACKAGES=1 chezmoi apply
```

Do not run package bootstrap unless explicitly requested; it can invoke Homebrew or apt.

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

### Symlink Management (Dotbot + Chezmoi Migration)

All config files live in this repo and are symlinked into place by dotbot. The Dotbot authoritative mapping is `install.conf.yaml`. Adding a new tool for the stable installer means: (1) create its config directory here, (2) add a `link:` entry to `install.conf.yaml`, (3) optionally add an `init.zsh`/`init.sh` script and reference it in the `shell:` section.

During the chezmoi migration, mirror new links into `chezmoi/` using `symlink_*` source-state entries and update `.chezmoiignore.tmpl` for OS/profile-specific applicability.

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
# Default shared profile
./install

# Private machine: includes pi-mcp-adapter and private MCP setup
PI_PROFILE=private ./install

# Work machine: excludes private MCP
PI_PROFILE=work ./install
```

Dotbot installs Pi if missing with:

```sh
npm install -g --ignore-scripts @earendil-works/pi-coding-agent
```

Then it runs `pi/scripts/apply-profile.sh "$PI_PROFILE"` and `pi update --extensions`.

Important files:

- `pi/config/settings.common.json` — shared profile without MCP
- `pi/config/settings.work.json` — work profile without private MCP
- `pi/config/settings.private.json` — private profile with `npm:pi-mcp-adapter`
- `pi/config/rtk-optimizer.json` — shared `pi-rtk-optimizer` config, exposed via `pi/extensions/pi-rtk-optimizer/config.json`
- `pi/packages/base/` — shared Pi package for portable extensions/skills/prompts/themes
- `pi/mcp/private.mcp.example.json` — private MCP template using environment-variable secrets
- `pi/AGENT.md` — detailed Pi-specific agent notes

Chezmoi links:

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
