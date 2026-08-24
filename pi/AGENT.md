# Pi Agent Notes

This directory contains the dotfiles-managed Pi setup.

## Installation via chezmoi

Pi is linked by the repository bootstrap:

```bash
# Default Linux profile: common settings
~/.dotfiles/install

# Private machine: enables pi-mcp-adapter and private MCP profile handling
CHEZMOI_PROFILE=private-mac ~/.dotfiles/install

# Work machine: no private MCP
CHEZMOI_PROFILE=work-mac ~/.dotfiles/install
```

## Profiles

Profile seed files live in `pi/config/`:

- `settings.common.json` — shared default; no MCP adapter.
- `settings.work.json` — work profile; no private MCP.
- `settings.private.json` — private profile; includes `npm:pi-mcp-adapter`.

`~/.pi/agent/settings.json` is intentionally a local mutable file, not a symlink back into Git. Chezmoi creates it from the active profile seed only when it is missing, so Pi can update local settings without dirtying this repository.

Apply manually when needed:

```bash
~/.dotfiles/pi/scripts/apply-profile.sh common
~/.dotfiles/pi/scripts/apply-profile.sh work
~/.dotfiles/pi/scripts/apply-profile.sh private
```

The script copies the selected seed into:

```text
~/.pi/agent/settings.json
```

It backs up an existing settings file first, then keeps the active file local and mutable.

It also links shared local resources:

```text
~/.pi/agent/extensions -> ~/.dotfiles/pi/extensions
~/.pi/agent/themes     -> ~/.dotfiles/pi/themes
```

Chezmoi manages these Pi entries:

```text
~/.pi/agent/settings.json created from profile-specific pi/config/settings.*.json when missing
~/.pi/agent/extensions    -> ~/.dotfiles/pi/extensions
~/.pi/agent/themes        -> ~/.dotfiles/pi/themes
~/.pi/agent/mcp.json      -> ~/.config/mcp/mcp.json (private-mac only)
```

Profile mapping:

- `private-mac` -> `settings.private.json`
- `work-mac` -> `settings.work.json`
- `linux-home` -> `settings.common.json`

Use `chezmoi apply --exclude scripts` for symlinks only. The private MCP bootstrap script runs only when scripts are included and creates `~/.config/mcp/mcp.json` from the example if missing.

## Shared Pi Package

Portable Pi resources live in:

```text
pi/packages/base/
```

Use this package for resources that should be available on every machine:

- shared extensions
- skills
- prompts
- themes

The profile settings reference it as a local package:

```json
"~/.dotfiles/pi/packages/base"
```

## MCP and Secrets

Private MCP config is intentionally not installed on work machines.

The template is:

```text
pi/mcp/private.mcp.example.json
```

On private machines, `apply-profile.sh private` or the chezmoi one-time script creates this local file if missing:

```text
~/.config/mcp/mcp.json
```

The active Pi MCP file is linked from:

```text
~/.pi/agent/mcp.json -> ~/.config/mcp/mcp.json
```

Never commit real tokens. Use environment variables or a secret manager:

```bash
export HOMEASSISTANT_TOKEN='...'
export PROXMOX_TOKEN_VALUE='...'
```

Keep these Pi runtime files local and out of Git:

```text
~/.pi/agent/auth.json
~/.pi/agent/sessions/
~/.pi/agent/trust.json
~/.pi/agent/npm/
~/.pi/agent/git/
~/.pi/agent/mcp-cache.json
```
