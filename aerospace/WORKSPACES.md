# Workspace setup

- Alt+1 `1-💼-Work`, LG: Chrome left 60%, Obsidian right 40%; Chrome windows stack vertically. WorkingHours floats.
- Alt+2 `2-📅-Plan`, LG: Gmail left; Calendar above Things on right.
- Alt+3 `3-🤖-Agents`, LG: Hermes, Pi Desktop, Ollama, horizontal tiles.
- Alt+4 `4-🏡-Personal`, LG: Brave, Telegram, WhatsApp, Spotify, Raindrop.io.
- Alt+5 `5-💬-Comms`, built-in: Slack.
- Alt+Shift+R: reroute open apps and rebuild layouts without launching or closing apps.
- Hyper+H (Cmd+Ctrl+Alt+Shift+H): launch/focus Hermes Agent using `com.nousresearch.hermes-bundled`. Newly detected windows route to Agents.

Workspaces 1–4 prefer `LG HDR WQHD`, falling back to `built-in`; workspace 5 is pinned to `built-in`. Forced assignments prevent moving these workspaces with Alt+Shift+Tab. Disconnect/reconnect behavior is configured, not physically tested. Unused workspaces 6–9/A–F remain available.

Routing runs when windows are detected. Nested splits are rebuilt at startup and with Alt+Shift+R. If apps open after startup restore, use the shortcut once they are open.

## Files and dependencies

`~/.aerospace.toml` links to `~/.dotfiles/aerospace/aerospace.toml`. Helpers and tests are tracked alongside it; the configuration calls the dotfiles copies, not the older local copies under `~/.config/aerospace`.

`restore-layout.py` requires Homebrew Python, AeroSpace and macOS osascript/AppKit. Horizontal gaps must be scalar. A nonblocking lock prevents overlapping restores. `follow-clawd.sh` keeps Clawd overlays on the active workspace.

SwiftBar startup and installation are documented in `../swiftbar/README.md`. SketchyBar startup/event hooks are disabled, but its package/config remain available. Outer top gap is 20px.

## Validate

```sh
aerospace reload-config --dry-run --no-gui
/opt/homebrew/bin/python3 -B ~/.dotfiles/aerospace/test_restore_layout.py
/opt/homebrew/bin/python3 -B ~/.dotfiles/aerospace/restore-layout.py --plan
```

Reload with `aerospace reload-config --no-gui`. Reloading alone does not reroute existing windows; use Alt+Shift+R when a full layout restore is intended.
