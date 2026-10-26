# AeroSpace workspace strip for SwiftBar

`plugins/aerospace.sh` is the **only** SwiftBar plugin entrypoint. Keep `lib/`,
`settings.json`, tests and this README outside the selected plugin directory.
Point SwiftBar at `~/.config/swiftbar/plugins` after linking the complete
`swiftbar` directory to `~/.config/swiftbar` (installation/preferences are handled
separately). The wrapper resolves symlinks; no checkout path is hardcoded.
Requires `/opt/homebrew/bin/python3` and `/opt/homebrew/bin/aerospace`.

## Install / restore on this Mac

```sh
brew install --cask swiftbar
brew install python
bash ~/.dotfiles/swiftbar/setup.sh
```

The setup script safely links `~/.config/swiftbar` to this checkout and sets
SwiftBar's PluginDirectory to its `plugins/` subdirectory. It refuses to replace
an unrelated existing directory. Run with `--no-launch` to configure without
opening SwiftBar. Homebrew's common Brewfile installs SwiftBar/Python and invokes
this no-launch setup; chezmoi manages the same symlink on macOS only.

AeroSpace's `after-startup-command` opens SwiftBar at login alongside its existing
layout restore. No extra launch agent or duplicate login item is installed.
SketchyBar startup stays disabled, including its old Brewfile postinstall hook.

If Ice hides a new menu-bar item, use Ice Settings → Menu Bar Layout to move the
SwiftBar workspace strip into Visible. The original AeroSpace indicator is left
unchanged as a fallback; it can be moved into Ice's Hidden section. Do not quit
AeroSpace to hide its indicator: that would stop window management.

## Behavior

One header contains all configured workspaces that are occupied **or** visible
on any monitor, in settings order. Focused workspace is **bold** (`md=true`),
not every visible workspace. All configured workspaces remain clickable in the
dropdown, including empty hidden ones. Clicks call AeroSpace directly using
`bash`, `param1=workspace`, quoted `param2`, `terminal=false`, `refresh=true`.
No workspace switching occurs merely by starting the plugin.

Edit `settings.json` to change `size` (default 15; range 6–72), optional `font`
(macOS font name, or null), and ordered `workspaces` (`name` is the exact
AeroSpace identifier; `label` is independent display text). Labels must not
contain ASCII pipes, asterisks or control characters. Unicode `│` separates
labels without colliding with SwiftBar's ASCII `|` parameter delimiter.
Settings are re-read on events and on a 15-second reconciliation tick.

The plugin subscribes to AeroSpace 0.21.3 `subscribe --all`. The subscription's
initial events close the startup snapshot/subscription race. Events trigger fresh
read-only snapshots; a 15-second reconciliation catches occupancy changes even
if the server emits no focus event. Duplicate frames are suppressed. A missing
or stopped AeroSpace server shows a waiting header and retries every two seconds;
errors go to stderr. SIGTERM stops the owned subscription process.

## Protocol and formatting

The [authoritative SwiftBar README](https://github.com/swiftbar/SwiftBar#streamable)
defines `<swiftbar.type>streamable</swiftbar.type>` and a standalone `~~~` line
that **resets** the menu. The first frame prints immediately; each changed frame
starts with `~~~\n`, then one header, `---`, and dropdown lines. Output is flushed
unbuffered; the filename deliberately has no refresh interval.

SwiftBar documents Markdown bold and ANSI separately, but does not promise
reliable combined attributed-text formatting. This plugin intentionally uses
**Markdown only**, with no ANSI escapes or `ansi=true`, avoiding formatting
conflicts. Per-workspace colors in the single header are not enabled.

## Read-only verification

```sh
./plugins/aerospace.sh --once
/opt/homebrew/bin/python3 -B -m unittest discover -s tests -v
/bin/sh -n plugins/aerospace.sh
```

`--once` prints one snapshot and exits; it never subscribes or changes focus.
The test suite includes a live read-only snapshot test, so AeroSpace must be
running for the complete suite. Stream framing, failure recovery, settings
validation and timeout retry are also tested without changing live settings.
No macOS preferences or native AeroSpace indicator configuration are changed here.
