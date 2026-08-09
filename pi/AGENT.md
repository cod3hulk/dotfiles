# Pi Agent Notes

This directory contains the dotfiles-managed Pi setup.

## Installation via Dotbot

Pi is installed and configured by the repository bootstrap:

```bash
# Default profile: common
~/.dotfiles/install

# Private machine: enables pi-mcp-adapter and private MCP profile handling
PI_PROFILE=private ~/.dotfiles/install

# Work machine: no private MCP
PI_PROFILE=work ~/.dotfiles/install
```

`install.conf.yaml` runs these Pi-related steps:

1. Install Pi if missing:
   ```bash
   npm install -g --ignore-scripts @earendil-works/pi-coding-agent
   ```
2. Apply the selected profile with `pi/scripts/apply-profile.sh`.
3. Run `pi update --extensions` to install/update configured Pi packages.

## Profiles

Profile files live in `pi/config/`:

- `settings.common.json` — shared default; no MCP adapter.
- `settings.work.json` — work profile; no private MCP.
- `settings.private.json` — private profile; includes `npm:pi-mcp-adapter`.

Apply manually when needed:

```bash
~/.dotfiles/pi/scripts/apply-profile.sh common
~/.dotfiles/pi/scripts/apply-profile.sh work
~/.dotfiles/pi/scripts/apply-profile.sh private
```

The script links the selected file to:

```text
~/.pi/agent/settings.json
```

It also links shared local resources:

```text
~/.pi/agent/extensions -> ~/.dotfiles/pi/extensions
~/.pi/agent/themes     -> ~/.dotfiles/pi/themes
```

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

On private machines, `apply-profile.sh private` creates this local file if missing:

```text
~/.config/mcp/mcp.json
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
