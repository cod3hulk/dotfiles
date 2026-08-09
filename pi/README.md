# Pi dotfiles

This directory separates portable Pi resources from host-specific configuration.

## Layout

- `packages/base/` — shared Pi package for extensions, skills, prompts, themes.
- `config/settings.common.json` — shared profile without private MCP.
- `config/settings.private.json` — private profile with `pi-mcp-adapter` enabled.
- `config/settings.work.json` — work profile without MCP.
- `config/rtk-optimizer.json` — shared pi-rtk-optimizer tuning.
- `mcp/private.mcp.example.json` — private MCP example using env-var secrets.
- `scripts/apply-profile.sh` — links a profile into `~/.pi/agent`.

## Apply

Private machine:

```bash
~/.dotfiles/pi/scripts/apply-profile.sh private
```

Work machine:

```bash
~/.dotfiles/pi/scripts/apply-profile.sh work
```

Common/minimal machine:

```bash
~/.dotfiles/pi/scripts/apply-profile.sh common
```

## Secrets

Do not commit tokens. Provide them via your shell or a secret manager:

```bash
export HOMEASSISTANT_TOKEN='...'
export PROXMOX_TOKEN_VALUE='...'
```

Your existing `~/.pi/agent/auth.json`, `sessions/`, `trust.json`, `npm/`, and `git/` stay local and should not be synced.
