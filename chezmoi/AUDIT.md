# Dotbot to chezmoi link audit

Status: private Mac and Linux profiles have been tested with `chezmoi diff --exclude scripts` and `chezmoi apply --exclude scripts`. `./install` now uses the chezmoi installer by default; the legacy Dotbot installer has been removed.

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
| `~/.tmux/plugins/tpm` | managed as external | archive from `tmux-plugins/tpm` |
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
| `~/.pi/agent/themes` | managed | symlink to `pi/themes` |
| `~/.pi/agent/extensions` | managed | symlink to `pi/extensions`; includes tracked `pi-rtk-optimizer` config symlink |
| `~/.pi/agent/settings.json` | managed | profile-specific symlink to `pi/config/settings.{private,work,common}.json` |
| `~/.pi/agent/mcp.json` | managed for `private-mac` | symlink to local secret file `~/.config/mcp/mcp.json`; ignored otherwise |

## Chezmoi additions not present as Dotbot links

| Target | Purpose |
|---|---|
| `~/.hushlogin` | replaces former shell hook `touch ~/.hushlogin` |
| `~/.zgen` | external archive replaces former `zgen/init.zsh` clone hook |
| `~/.local/bin/fzf` | Linux external archive replaces shell-script GitHub release parsing |

## Package bootstrap

Chezmoi scripts and externals are present but package-manager side effects are opt-in. Package scripts use `run_onchange_*` where the rendered content includes the `CHEZMOI_INSTALL_PACKAGES` opt-in flag, so switching the flag from `0` to `1` retriggers the relevant bootstrap while normal `chezmoi apply` stays side-effect-light:

```sh
CHEZMOI_INSTALL_PACKAGES=1 chezmoi apply
```

Homebrew uses split manifests:

- `brew/Brewfile.common`
- `brew/Brewfile.private-mac`
- `brew/Brewfile.work-mac`

## Known follow-ups

1. Validate `work-mac` profile later on a macOS host.
