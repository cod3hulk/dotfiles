# Chezmoi migration

This directory is the experimental chezmoi source state for this dotfiles repo.

It is intended to run in parallel with the existing Dotbot setup during migration. See `AUDIT.md` for the Dotbot-to-chezmoi link coverage audit.

## Profiles

`./install-chezmoi` configures a machine profile in `~/.config/chezmoi/chezmoi.toml`:

- `private-mac`
- `work-mac`
- `linux-home`

You can preselect the profile non-interactively:

```sh
CHEZMOI_PROFILE=work-mac ./install-chezmoi
```

## Try locally

```sh
./install-chezmoi
chezmoi diff --exclude scripts
chezmoi apply --exclude scripts
```

Plain `chezmoi apply` is safe too: package scripts exit unless `CHEZMOI_INSTALL_PACKAGES=1` is set. During migration, `--exclude scripts` keeps diffs focused on symlinks.

`./install-chezmoi` writes `~/.config/chezmoi/chezmoi.toml` with this repo's `chezmoi/` directory as `sourceDir`. If you do not want to persist that config, use explicit source commands instead:

```sh
chezmoi -S ~/.dotfiles/chezmoi diff
chezmoi -S ~/.dotfiles/chezmoi apply
```

## Current scope

Migrated files are currently managed as symlinks back to this repo, so chezmoi can run in parallel with Dotbot.

Common files:

- `~/.zshrc` -> `zsh/zshrc.zsh`
- `~/.zprofile` -> `zsh/zprofile.zsh`
- `~/.tmux.conf` -> `tmux/tmux.conf`
- `~/.tigrc` -> `tig/tig.conf`
- `~/.ideavimrc` -> `intellij/ideavimrc`
- `~/.config/nvim` -> `nvim`
- `~/.local/bin/clipcopy` -> `scripts/clipcopy`
- `~/.pi/agent/settings.json` -> profile-specific `pi/config/settings.*.json`
- `~/.pi/agent/extensions` -> `pi/extensions`
- `~/.pi/agent/themes` -> `pi/themes`

Private macOS profile files:

- `~/.yabairc` -> `yabai/yabairc`
- `~/.skhdrc` -> `skhd/skhdrc`
- `~/.hammerspoon` -> `hammerspoon`
- `~/.config/karabiner` -> `karabiner`
- `~/.config/borders/bordersrc` -> `borders/bordersrc`

macOS files:

- Alacritty, Kitty, VS Code configs

Linux files:

- i3 config

Private Pi files:

- `~/.pi/agent/mcp.json` -> `~/.config/mcp/mcp.json` on `private-mac` only. The local file is created from `pi/mcp/private.mcp.example.json` by the one-time chezmoi script if missing.

Package bootstrap scripts are present as chezmoi scripts, but they are opt-in during migration:

```sh
CHEZMOI_INSTALL_PACKAGES=1 chezmoi apply
```

Homebrew dependencies are split for chezmoi:

- `brew/Brewfile.common` — shared macOS CLI/apps
- `brew/Brewfile.private-mac` — private Mac desktop/window-management apps
- `brew/Brewfile.work-mac` — work Mac specific apps, currently intentionally small

The legacy `brew/Brewfile` remains for the Dotbot installer until migration is completed.

Dotbot remains the authoritative installer until the migration is completed.
