# Chezmoi source state

This directory is the default chezmoi source state for this dotfiles repo.

Legacy Dotbot remains available via `./install-dotbot`. See `AUDIT.md` for the Dotbot-to-chezmoi link coverage audit.

## Profiles

Package/bootstrap scripts and external resources are selected from chezmoi's `.chezmoi.os` template data:

- Common externals — zgen and TPM are downloaded by `.chezmoiexternal.toml.tmpl` instead of relying on legacy Dotbot hooks/submodule checkouts in the target home.
- macOS/Darwin — Homebrew via `.chezmoiscripts/run_onchange_install-brew-packages.sh.tmpl`, plus Clawd on Desk dmg releases via `.chezmoiscripts/run_onchange_install-clawd-on-desk.sh.tmpl`.
- Linux — apt plus upstream Neovim releases via `.chezmoiscripts/run_onchange_install-linux-packages.sh.tmpl`, fzf via `.chezmoiexternal.toml.tmpl`, plus Clawd on Desk deb/AppImage releases via `.chezmoiscripts/run_onchange_install-clawd-on-desk.sh.tmpl`.

Profiles are selected by `chezmoi/.chezmoi.toml.tmpl`:

- hostname `cod3hulk` — selects the private profile automatically (`private-mac` on macOS, `linux-home` on Linux)
- any other hostname — prompts once, then persists `[data].profile` in `~/.config/chezmoi/chezmoi.toml`

You can override detection/prompting non-interactively:

```sh
CHEZMOI_PROFILE=work-mac ./install-chezmoi
```

## Apply

```sh
./install
```

`./install` and `./install-chezmoi` initialize chezmoi and apply the source state.

For a preview-only flow:

```sh
chezmoi -S ~/.dotfiles/chezmoi init
chezmoi -S ~/.dotfiles/chezmoi diff
```

Plain `chezmoi apply` is safe: package scripts exit unless `CHEZMOI_INSTALL_PACKAGES=1` is set.

`./install-chezmoi` uses `chezmoi init --source`, so `~/.config/chezmoi/chezmoi.toml` is rendered from `chezmoi/.chezmoi.toml.tmpl` with a persisted `[data].profile`. If you do not want to persist that config, use explicit source commands instead:

```sh
chezmoi -S ~/.dotfiles/chezmoi diff
chezmoi -S ~/.dotfiles/chezmoi apply
```

## Current scope

Managed files are currently symlinks back to this repo.

Common files:

- `~/.zgen` -> external archive `tarjoilija/zgen`
- `~/.tmux/plugins/tpm` -> external archive `tmux-plugins/tpm`
- `~/.zshrc` -> `zsh/zshrc.zsh`
- `~/.zprofile` -> `zsh/zprofile.zsh`
- `~/.tmux.conf` -> `tmux/tmux.conf`
- `~/.tigrc` -> `tig/tig.conf`
- `~/.ideavimrc` -> `intellij/ideavimrc`
- `~/.config/nvim` -> `nvim`
- `~/.local/bin/clipcopy` -> `scripts/clipcopy`
- `~/.hermes/skins/dracula.yaml` -> `hermes/skins/dracula.yaml`
- `~/.pi/agent/settings.json` -> profile-specific `pi/config/settings.*.json`
- `~/.pi/agent/extensions` -> `pi/extensions`
- `~/.pi/agent/themes` -> `pi/themes`

Hermes' Dracula skin is linked independently of Nous Portal / Skill Sync. The
`.chezmoiscripts/run_onchange_after_activate-hermes-dracula.sh` script activates it with
`hermes config set display.skin dracula` when Hermes is installed. Secrets,
auth, memories, sessions, logs, caches, and other runtime state remain local.

The shared Pi profiles already include the portable RTK/headroom packages:
`npm:pi-rtk-optimizer` and `npm:@raquezha/noheadroom`.

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
CHEZMOI_INSTALL_PACKAGES=1 ./install
```

Homebrew dependencies are split for chezmoi:

- `brew/Brewfile.common` — shared macOS CLI/apps
- `brew/Brewfile.private-mac` — private Mac desktop/window-management apps
- `brew/Brewfile.work-mac` — work Mac specific apps, currently intentionally small

Refresh external resources explicitly with:

```sh
chezmoi -R apply
```

The legacy `brew/Brewfile` remains for the Dotbot installer until migration is completed.

Dotbot remains available as the legacy installer via `./install-dotbot`.
