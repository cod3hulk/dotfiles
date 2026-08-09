# Pi MCP profiles

Private MCP servers are intentionally separated from global Pi settings.

Use on private machines only:

```bash
mkdir -p ~/.config/mcp
cp ~/.dotfiles/pi/mcp/private.mcp.example.json ~/.config/mcp/mcp.json
```

Secrets must come from environment variables, not Git:

```bash
export HOMEASSISTANT_TOKEN='...'
export PROXMOX_TOKEN_VALUE='...'
```

Do not commit real tokens. If a real local override is needed inside this repo,
name it `private.mcp.json`; it is ignored by `.gitignore`.
