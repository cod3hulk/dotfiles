#!/usr/bin/env bash
set -euo pipefail

profile="${1:-}"
if [[ -z "$profile" || ! "$profile" =~ ^(common|private|work)$ ]]; then
  echo "Usage: $0 {common|private|work}" >&2
  exit 2
fi

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
pi_dir="$HOME/.pi/agent"

mkdir -p "$pi_dir"
ln -sfn "$repo_dir/pi/config/settings.$profile.json" "$pi_dir/settings.json"

# Keep existing auto-discovered local extensions/themes available via repo links.
ln -sfn "$repo_dir/pi/extensions" "$pi_dir/extensions"
ln -sfn "$repo_dir/pi/themes" "$pi_dir/themes"

# pi-rtk-optimizer reads its own config from the extension config directory.
# The repo extension directory contains a tracked symlink:
# pi/extensions/pi-rtk-optimizer/config.json -> ../../config/rtk-optimizer.json

if [[ "$profile" == "private" ]]; then
  mkdir -p "$HOME/.config/mcp"
  if [[ ! -e "$HOME/.config/mcp/mcp.json" ]]; then
    cp "$repo_dir/pi/mcp/private.mcp.example.json" "$HOME/.config/mcp/mcp.json"
    chmod 600 "$HOME/.config/mcp/mcp.json"
    echo "Created ~/.config/mcp/mcp.json from private example. Fill env vars for tokens."
  else
    echo "Keeping existing ~/.config/mcp/mcp.json"
  fi
  ln -sfn "$HOME/.config/mcp/mcp.json" "$pi_dir/mcp.json"
else
  rm -f "$pi_dir/mcp.json"
  echo "Profile '$profile' does not install private MCP config."
fi

echo "Linked Pi profile '$profile'. Restart pi or run /reload."
