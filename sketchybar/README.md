# SketchyBar

AeroSpace workspace indicator for the private Mac profile. Chosen over
[simple-bar](https://github.com/Jean-Tinland/simple-bar) because it needs no
Übersicht dependency and its config is plain shell, so it fits the existing
chezmoi symlink + Brewfile `postinstall` pattern already used by `borders/`
(same upstream author, same event model).

## Files

| File | Purpose |
|---|---|
| `sketchybarrc` | bar geometry, item definitions, event registration |
| `colors.sh` | Dracula palette; `ACTIVE`/`INACTIVE` mirror `borders/bordersrc` |
| `icons.sh` | Hack Nerd Font glyphs (font already in `Brewfile.common`) |
| `plugins/aerospace.sh` | workspace highlight + hide-empty logic |
| `plugins/front_app.sh` | focused app name |
| `plugins/clock.sh` | date and 24h time |
| `plugins/battery.sh` | battery ramp, warns below 20% |
| `init.sh` | Brewfile `postinstall` hook — restarts the service |

## Workspace behaviour

- **Focused** — purple fill (`ACTIVE`, same hex as the active window border)
- **Occupied, unfocused** — white glyph, no fill
- **Empty, unfocused** — hidden, so 16 persistent workspaces don't crowd the bar

Updates are event-driven, no polling. Two hooks in `aerospace/aerospace.toml`
both trigger the custom `aerospace_workspace_change` event:

- `exec-on-workspace-change` — switching workspaces. Passes
  `$AEROSPACE_FOCUSED_WORKSPACE`, which the plugin reads as `$FOCUSED_WORKSPACE`
  to skip a subprocess.
- `on-focus-changed` — needed because moving a window with `alt-shift-<key>`
  does **not** change the focused workspace, so `exec-on-workspace-change` alone
  left newly occupied workspaces hidden. Passes no env var; the plugin falls
  back to querying AeroSpace.

AeroSpace has no window-moved callback, and SketchyBar's built-in
`space_windows_change` does not help — it tracks macOS spaces, while AeroSpace
keeps everything on one space and hides windows instead.

Workspace items use `updates=on`, not the `when_shown` default: a hidden item
with `when_shown` never runs its script, so an empty workspace could never
discover it had become occupied.

Workspace items are built from `aerospace list-workspaces --all`, so
non-persistent workspaces appear too. Adding a workspace to
`persistent-workspaces` requires a `sketchybar --reload` (or a relogin) to
register a new item.

## Interaction with the native menu bar

**MeetingBar stays in the native macOS menu bar.** It cannot be integrated here:

- `eventStoreProvider = "Google Calendar API"` — it bypasses macOS Calendar
  (EventKit), so `~/Library/Calendars` is empty and `icalBuddy` sees nothing
- its only URL scheme command is `meetingbar://preferences` — no next-event query
- it is sandboxed (`~/Library/Containers/leits.MeetingBar`) and ships no CLI or
  AppleScript dictionary

Keep `jordanbaird-ice` installed to tidy the native bar around it.

To render meetings here instead, add the Google account under System Settings →
Internet Accounts (populating EventKit), then `brew install ical-buddy` and add
a plugin. MeetingBar is unaffected by that change — it stays on the Google API
path.

## Commands

```sh
brew services restart sketchybar   # after editing sketchybarrc
sketchybar --reload                # faster: reload config only
```

## Install caveat on the work Mac

`brew install FelixKratz/formulae/sketchybar` fails behind Netskope TLS
interception:

```
curl: (60) SSL certificate problem: self signed certificate in certificate chain
```

The shell exports `CURL_CA_BUNDLE`/`SSL_CERT_FILE` pointing at
`~/.nscacert_combined.pem`, but Homebrew sanitizes the environment, so its curl
falls back to the system bundle and rejects the intercepted chain. The formula's
`documentation.tar.gz` fetch is what trips. `HOMEBREW_CURLRC=<file>` did not help
in testing.

Workaround used — build from source and drop the binary in place:

```sh
git clone --depth 1 --branch v2.24.0 https://github.com/FelixKratz/SketchyBar.git
cd SketchyBar && make -j12
cp bin/sketchybar /opt/homebrew/bin/sketchybar
```

Because of this, `brew services` has no plist for sketchybar on that machine, so
`after-startup-command` in `aerospace/aerospace.toml` (which calls
`brew services start sketchybar`) will not launch it there. Either install the
formula successfully on a non-intercepted network, or swap that line for
`exec-and-forget /opt/homebrew/bin/sketchybar`.
