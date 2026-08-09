# Pi dotfiles

This directory separates portable Pi resources from host-specific configuration.

## Layout

- `packages/base/` — shared Pi package for extensions, skills, prompts, themes.
- `config/settings.common.json` — shared profile without private MCP.
- `config/settings.private.json` — private profile with `pi-mcp-adapter` enabled.
- `config/settings.work.json` — work profile without MCP.
- `config/rtk-optimizer.json` — shared pi-rtk-optimizer tuning, exposed at `pi/extensions/pi-rtk-optimizer/config.json`.
- `mcp/private.mcp.example.json` — private MCP example using env-var secrets.
- `scripts/apply-profile.sh` — legacy/manual profile linker into `~/.pi/agent`.

## Apply

Preferred via chezmoi:

```bash
CHEZMOI_PROFILE=private-mac ~/.dotfiles/install-chezmoi
chezmoi apply --exclude scripts
```

Profile mapping:

- `private-mac` -> `pi/config/settings.private.json`
- `work-mac` -> `pi/config/settings.work.json`
- `linux-home` -> `pi/config/settings.common.json`

Legacy/manual profile linker:

```bash
~/.dotfiles/pi/scripts/apply-profile.sh private
~/.dotfiles/pi/scripts/apply-profile.sh work
~/.dotfiles/pi/scripts/apply-profile.sh common
```

## Secrets

Do not commit tokens. Provide them via your shell or a secret manager:

```bash
export HOMEASSISTANT_TOKEN='...'
export PROXMOX_TOKEN_VALUE='...'
```

Your existing `~/.pi/agent/auth.json`, `sessions/`, `trust.json`, `npm/`, `git/`, `models-store.json`, and `mcp-cache.json` stay local and should not be synced. Private MCP secrets live in `~/.config/mcp/mcp.json`; chezmoi links `~/.pi/agent/mcp.json` to it only on the `private-mac` profile.
