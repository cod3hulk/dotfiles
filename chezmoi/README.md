# Chezmoi migration

This directory is the experimental chezmoi source state for this dotfiles repo.

It is intended to run in parallel with the existing Dotbot setup during migration.

## Try locally

```sh
./install-chezmoi
chezmoi apply
```

`./install-chezmoi` writes `~/.config/chezmoi/chezmoi.toml` with this repo's `chezmoi/` directory as `sourceDir`. If you do not want to persist that config, use explicit source commands instead:

```sh
chezmoi -S ~/.dotfiles/chezmoi diff
chezmoi -S ~/.dotfiles/chezmoi apply
```

## Current scope

Migrated first, low-risk files as symlinks back to this repo, so chezmoi can run in parallel with Dotbot:

- `~/.tigrc` -> `tig/tig.conf`
- `~/.ideavimrc` -> `intellij/ideavimrc`
- `~/.tmux.conf` -> `tmux/tmux.conf`
- `~/.zprofile` -> `zsh/zprofile.zsh`

Package bootstrap scripts are present as chezmoi scripts, but they are opt-in during migration:

```sh
CHEZMOI_INSTALL_PACKAGES=1 chezmoi apply
```

Dotbot remains the authoritative installer until the migration is completed.
