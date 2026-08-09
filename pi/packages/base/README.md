# @tave/pi-base

Shared Pi package for resources that should load on every machine.

Put only portable, non-secret resources here:

- `extensions/` shared Pi extensions
- `skills/` shared skills
- `prompts/` shared prompt templates
- `themes/` shared themes

Keep host-specific MCP servers, credentials, sessions, and trust decisions out of this package.
