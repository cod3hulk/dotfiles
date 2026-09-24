# SketchyBar

AeroSpace workspace indicator plus a next-meeting item. Chosen over
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

Glyphs in `icons.sh` must be literal UTF-8 bytes. macOS ships bash 3.2, which
does not support `$'\uXXXX'` escapes — they pass through as the literal text
`\uf017` and the icon silently vanishes.
| `plugins/aerospace.sh` | workspace highlight + hide-empty logic |
| `plugins/front_app.sh` | focused app name |
| `plugins/clock.sh` | date and 24h time |
| `plugins/battery.sh` | battery ramp, warns below 20% |
| `plugins/meeting.sh` | next meeting from EventKit via `icalBuddy` |
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

### Why one driver item instead of per-item scripts

The workspace items carry no script. A single hidden `space_driver` item owns the
subscription and repaints all of them in one batched `sketchybar` message.

The first version gave every workspace item its own script, which meant one
`aerospace list-workspaces --focused` plus one `aerospace list-windows --count`
per item. Each `aerospace` CLI call costs ~45ms, so a switch on this
16-workspace setup cost ~1.33s and lagged visibly.

The driver makes two aerospace calls total, or one when
`$FOCUSED_WORKSPACE` arrives via `exec-on-workspace-change`. Measured on a
16-workspace setup:

| Path | Before | After |
|---|---|---|
| workspace switch (env var) | ~1330ms | ~70ms |
| focus change / window move | ~1330ms | ~120ms |

`list-windows --all --format '%{workspace}'` returns the workspace of every
window in one call, which replaces the per-workspace count queries.

`space_driver` needs `updates=on`: it is permanently `drawing=off`, and with the
`when_shown` default a hidden item never runs its script at all.

Workspace items are built from `aerospace list-workspaces --all`, so
non-persistent workspaces appear too. Adding a workspace to
`persistent-workspaces` requires a `sketchybar --reload` (or a relogin) to
register a new item.

## Next meeting

`plugins/meeting.sh` reads EventKit through `icalBuddy` (`brew "ical-buddy"` in
`Brewfile.common`). Display escalates with urgency:

| Time until | Colour | Example |
|---|---|---|
| > 60 min | white | `Standup · 2h15m` |
| 16–60 min | white | `Standup · 42m` |
| ≤ 15 min | orange | `Standup · 12m` |
| ≤ 5 min | red | `Standup · 4m` |
| in progress | red | `Standup · now` |
| none upcoming | hidden | — |

A meeting stops showing 15 minutes after it starts (`STALE_AFTER_MIN`), then the
next one takes over. Titles truncate at 28 chars so a long invite can't push the
clock offscreen. All-day events are excluded (`-ea`). Clicking the item opens
MeetingBar.

Like the workspace items, this needs `updates=on`: with the `when_shown` default
the hidden item would never run its script and so could never un-hide itself.

Three `icalBuddy` details that are easy to get wrong:

- in `-ps` the pipes are delimiters, not part of the separator, so `"|@@|"`
  produces a literal `@@`
- datetimes render as `2026-09-24 at 13:57`, not `2026-09-24 13:57`, so date and
  time are extracted separately rather than parsed as one string
- `to:` is **day-granular** and silently ignores any time component, so
  `to:"2026-09-25 10:00"` and `to:"2026-09-25 23:00"` return identical results.
  The lookahead is therefore `LOOKAHEAD_DAYS`, not hours. `1` means "today and
  tomorrow", so tomorrow's first meeting still shows late in the evening rather
  than the item going blank.

All-day events are filtered by `-ea`, which correctly excludes entries like a
full-day `OOO` block so they cannot occupy the slot ahead of a real meeting.

### Calendar source

EventKit holds both the personal iCloud calendars and, since the Google account
was added under **System Settings → Internet Accounts**, the work ones
(`tomas.ave@zendesk.com`, `Bridge Team`). No plugin change was needed — it picked
them up automatically.

Verify the work calendars are present with:

```sh
icalBuddy calendars | grep -i zendesk
```

Note that `~/Library/Calendars` being empty is *not* a reliable emptiness check;
it stays empty even when EventKit has calendars. Ask `icalBuddy` instead.

## Interaction with the native menu bar

**MeetingBar stays in the native macOS menu bar** and is not replaced by the item
above. It cannot be driven from here:

- `eventStoreProvider = "Google Calendar API"` — it bypasses EventKit entirely,
  so it and `meeting.sh` read different sources
- its only URL scheme command is `meetingbar://preferences` — no next-event query
- it is sandboxed (`~/Library/Containers/leits.MeetingBar`) and ships no CLI or
  AppleScript dictionary

Adding the account to Internet Accounts does not affect MeetingBar — it stays on
the Google API path. Once the bar item shows work meetings reliably, MeetingBar
becomes redundant unless its notifications and auto-join are wanted, at which
point `jordanbaird-ice` could go too.

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
