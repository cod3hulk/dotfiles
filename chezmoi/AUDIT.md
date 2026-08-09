# Dotbot to chezmoi link audit

Status: private Mac and Linux profiles have been tested with `chezmoi diff --exclude scripts` and `chezmoi apply --exclude scripts`.

## Coverage

| Dotbot target | Chezmoi status | Notes |
|---|---|---|
| `~/.tmux.conf` | managed | symlink to `tmux/tmux.conf` |
| `~/.tigrc` | managed | symlink to `tig/tig.conf` |
| `~/.yabairc` | managed for `private-mac` | ignored otherwise |
| `~/.limelight` | managed for `private-mac` | ignored otherwise |
| `~/.skhdrc` | managed for `private-mac` | ignored otherwise |
| `~/.config/nvim` | managed | symlink to `nvim/` |
| `~/.ideavimrc` | managed | symlink to `intellij/ideavimrc` |
| `~/.zshrc` | managed | symlink to `zsh/zshrc.zsh` |
| `~/.zprofile` | managed | symlink to `zsh/zprofile.zsh` |
| `~/.hammerspoon` | managed for `private-mac` | ignored otherwise |
| `~/.tmux/plugins/tpm` | managed | symlink to `tmux/tpm` |
| `~/.tmux/scripts` | managed | symlink to `tmux/scripts` |
| `~/.config/alacritty/alacritty.yml` | managed on macOS | ignored on Linux |
| `~/.config/alacritty/alacritty.toml` | managed on macOS | ignored on Linux |
| `~/.config/i3/config` | managed on Linux | ignored on macOS |
| `~/.config/Code/User/settings.json` | managed on macOS | ignored on Linux |
| `~/.config/Code/User/keybindings.json` | managed on macOS | ignored on Linux |
| `~/.config/karabiner` | managed for `private-mac` | ignored otherwise |
| `~/.config/kitty` | managed on macOS | ignored on Linux |
| `~/.config/borders/bordersrc` | managed for `private-mac` | ignored otherwise |
| `~/.config/tmux-powerline/config.sh` | managed | symlink to `tmux/tmux-powerline.sh` |
| `~/.tmux/plugins/tmux-which-key/config.yaml` | managed | symlink to `tmux/which-key.yaml` |
| `~/.local/bin/clipcopy` | managed | symlink to `scripts/clipcopy` |
| `~/.pi/agent/themes` | intentionally omitted | Pi package/profile management needs a separate migration pass to avoid overwriting local Pi state |
| `~/.pi/agent/extensions` | intentionally omitted | Pi package/profile management needs a separate migration pass to avoid overwriting local Pi state |

## Chezmoi additions not present as Dotbot links

| Target | Purpose |
|---|---|
| `~/.hushlogin` | replaces Dotbot shell hook `touch ~/.hushlogin` |

## Package bootstrap

Chezmoi scripts are present but opt-in:

```sh
CHEZMOI_INSTALL_PACKAGES=1 chezmoi apply
```

Homebrew uses split manifests:

- `brew/Brewfile.common`
- `brew/Brewfile.private-mac`
- `brew/Brewfile.work-mac`

The legacy `brew/Brewfile` remains for Dotbot until the migration becomes the default installer.

## Known follow-ups

1. Validate `work-mac` profile later.
2. Migrate Pi settings/extensions/themes separately.
3. Decide whether `./install` should become the chezmoi installer or Dotbot should remain the stable default.
