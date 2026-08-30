// Place floating windows on a yabai-style grid.
//
// AeroSpace cannot position floating windows itself — both `aerospace move` and
// `aerospace resize` reject them (see AeroSpace issue #9), so all geometry has
// to go through the macOS Accessibility API.
//
// AeroSpace window ids are CGWindowIDs, so AX elements are matched against them
// via _AXUIElementGetWindow, the same private symbol AeroSpace and yabai use.
// on-window-detected callbacks get an id for free in AEROSPACE_WINDOW_ID;
// keybindings do not, so those start from the frontmost window and derive the id
// from it. Either way we end up with both the AX element and AeroSpace's own view
// of the window, which is what --toggle needs.
//
// Grid geometry mirrors yabai's `grid=<rows>:<cols>:<col>:<row>:<cols-wide>:<rows-high>`.
//
// --fullscreen is here for the same reason: `aerospace fullscreen` is a silent
// no-op on floating windows, so there is otherwise no way back out of one.
//
// Keep the logic in functions rather than at top level: `-O` miscompiled closures
// over top-level vars here and segfaulted.
//
// Build: swiftc -O float-place.swift -o float-place
// Usage from aerospace.toml: exec-and-forget "$HOME/.dotfiles/aerospace/float-place" [flags]

import AppKit
import ApplicationServices
import Foundation

@_silgen_name("_AXUIElementGetWindow")
func _AXUIElementGetWindow(_ element: AXUIElement, _ out: UnsafeMutablePointer<CGWindowID>) -> AXError

let aerospace = "/opt/homebrew/bin/aerospace"
let debug = ProcessInfo.processInfo.environment["FLOAT_PLACE_DEBUG"] == "1"

func log(_ msg: String) {
    guard debug else { return }
    let ts = DateFormatter()
    ts.dateFormat = "HH:mm:ss.SSS"
    let line = "[\(ts.string(from: Date()))] \(msg)\n"
    let path = "/tmp/float-place.log"
    if !FileManager.default.fileExists(atPath: path) {
        FileManager.default.createFile(atPath: path, contents: nil)
    }
    if let handle = try? FileHandle(forWritingTo: URL(fileURLWithPath: path)) {
        handle.seekToEndOfFile()
        handle.write(line.data(using: .utf8)!)
        handle.closeFile()
    }
}

func runAero(_ args: [String]) -> String {
    let task = Process()
    task.executableURL = URL(fileURLWithPath: aerospace)
    task.arguments = args
    let pipe = Pipe()
    task.standardOutput = pipe
    task.standardError = Pipe()
    try? task.run()
    task.waitUntilExit()
    let data = try? pipe.fileHandleForReading.readToEnd()
    return String(data: data ?? Data(), encoding: .utf8)?
        .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
}

// ── Argument parsing ────────────────────────────────────────────────

struct Grid {
    let rows, cols, col, row, width, height: CGFloat
}

func parseGrid(_ spec: String) -> Grid? {
    let p = spec.split(separator: ":").compactMap { Double($0) }
    guard p.count == 6, p[0] > 0, p[1] > 0, p[4] > 0, p[5] > 0 else { return nil }
    return Grid(rows: p[0], cols: p[1], col: p[2], row: p[3], width: p[4], height: p[5])
}

func usage() -> Never {
    FileHandle.standardError.write("""
        usage: float-place [--window-id <id>] [--grid R:C:X:Y:W:H] [--gaps <px>]
                           [--if-floating] [--toggle] [--fullscreen]

          --window-id    AeroSpace window id; defaults to $AEROSPACE_WINDOW_ID,
                         then to the frontmost window.
          --grid         yabai-style grid, e.g. 8:8:1:1:6:6 (centered 75%).
                         Omit to center at the window's current size.
          --gaps         inset the screen's visible frame by <px> before placing.
          --if-floating  do nothing unless the window is floating.
          --toggle       floating -> tiling, tiling -> floating + place.
          --fullscreen   toggle maximize; tiling windows are handed to AeroSpace.

        """.data(using: .utf8)!)
    exit(2)
}

var argWindowId: UInt32? = nil
var grid: Grid? = nil
var gaps: CGFloat = 0
var ifFloating = false
var toggle = false
var fullscreen = false

var args = Array(CommandLine.arguments.dropFirst())
while let arg = args.first {
    args.removeFirst()
    switch arg {
    case "--window-id":
        guard let v = args.first, let id = UInt32(v) else { usage() }
        argWindowId = id
        args.removeFirst()
    case "--grid":
        guard let v = args.first, let g = parseGrid(v) else { usage() }
        grid = g
        args.removeFirst()
    case "--gaps":
        guard let v = args.first, let g = Double(v) else { usage() }
        gaps = CGFloat(g)
        args.removeFirst()
    case "--if-floating":
        ifFloating = true
    case "--toggle":
        toggle = true
    case "--fullscreen":
        fullscreen = true
    case "-h", "--help":
        usage()
    default:
        usage()
    }
}

// ── Window lookup ───────────────────────────────────────────────────

func axQueryWithRetry(_ element: AXUIElement, _ attr: String, _ retries: Int = 5) -> CFTypeRef? {
    var ref: CFTypeRef?
    for attempt in 0..<retries {
        let result = AXUIElementCopyAttributeValue(element, attr as CFString, &ref)
        if result == .success, ref != nil { return ref }
        log("AX query '\(attr)' attempt \(attempt + 1)/\(retries) failed: \(result.rawValue)")
        usleep(50_000)
    }
    return nil
}

/// AeroSpace's view of a window: its pid and layout, keyed by window id.
func aeroWindow(id: UInt32) -> (pid: pid_t, layout: String)? {
    let out = runAero(["list-windows", "--all", "--format", "%{window-id}|%{app-pid}|%{window-layout}"])
    for line in out.split(separator: "\n") {
        let parts = line.split(separator: "|", omittingEmptySubsequences: false)
        guard parts.count >= 3, UInt32(parts[0].trimmingCharacters(in: .whitespaces)) == id,
              let pid = pid_t(parts[1].trimmingCharacters(in: .whitespaces)) else { continue }
        return (pid, parts[2].trimmingCharacters(in: .whitespaces))
    }
    return nil
}

/// Find the AX element for a CGWindowID among the given app's windows.
func axWindow(pid: pid_t, id: UInt32) -> AXUIElement? {
    let axApp = AXUIElementCreateApplication(pid)
    guard let winsRef = axQueryWithRetry(axApp, kAXWindowsAttribute as String),
          let wins = winsRef as? [AXUIElement] else { return nil }
    for w in wins {
        var wid: CGWindowID = 0
        if _AXUIElementGetWindow(w, &wid) == .success, wid == id { return w }
    }
    return nil
}

// ── Geometry ────────────────────────────────────────────────────────

func axSize(_ win: AXUIElement) -> CGSize? {
    guard let val = axQueryWithRetry(win, kAXSizeAttribute as String, 2) else { return nil }
    var size = CGSize.zero
    AXValueGetValue(val as! AXValue, .cgSize, &size)
    return size.width > 0 && size.height > 0 ? size : nil
}

func axOrigin(_ win: AXUIElement) -> CGPoint? {
    guard let val = axQueryWithRetry(win, kAXPositionAttribute as String, 2) else { return nil }
    var pos = CGPoint.zero
    AXValueGetValue(val as! AXValue, .cgPoint, &pos)
    return pos
}

func axSet(_ win: AXUIElement, _ attr: String, _ value: inout CGPoint) {
    guard let v = AXValueCreate(.cgPoint, &value) else { return }
    AXUIElementSetAttributeValue(win, attr as CFString, v as CFTypeRef)
}

func axSet(_ win: AXUIElement, _ attr: String, _ value: inout CGSize) {
    guard let v = AXValueCreate(.cgSize, &value) else { return }
    AXUIElementSetAttributeValue(win, attr as CFString, v as CFTypeRef)
}

/// The screen containing the window's center, in AX (top-left origin) coordinates.
/// Returns the usable area already flipped, inset by `gaps`.
func targetArea(for win: AXUIElement) -> CGRect? {
    let screens = NSScreen.screens
    guard let primary = screens.first else { return nil }
    let primaryHeight = primary.frame.size.height

    /// NSScreen frames are bottom-left origin; AX is top-left origin.
    func flip(_ f: CGRect) -> CGRect {
        CGRect(x: f.origin.x, y: primaryHeight - (f.origin.y + f.size.height),
               width: f.size.width, height: f.size.height)
    }

    var center: CGPoint? = nil
    if let pos = axOrigin(win), let size = axSize(win) {
        center = CGPoint(x: pos.x + size.width / 2, y: pos.y + size.height / 2)
    }

    var screen = primary
    if let c = center {
        for s in screens where flip(s.frame).contains(c) {
            screen = s
            break
        }
    }
    return flip(screen.visibleFrame).insetBy(dx: gaps, dy: gaps)
}

/// The rectangle the window should end up inside: the grid cell if a grid was
/// given, otherwise the whole usable area.
func box(in area: CGRect) -> CGRect {
    guard let g = grid else { return area }
    let cellW = area.width / g.cols
    let cellH = area.height / g.rows
    return CGRect(x: area.minX + g.col * cellW,
                  y: area.minY + g.row * cellH,
                  width: g.width * cellW,
                  height: g.height * cellH)
}

func centered(_ size: CGSize, in box: CGRect) -> CGPoint {
    CGPoint(x: box.minX + (box.width - size.width) / 2,
            y: box.minY + (box.height - size.height) / 2)
}

/// Apps resist geometry changes while a float transition or their own layout
/// pass is still running, so keep reapplying briefly until it sticks.
func place(_ win: AXUIElement) {
    guard let area = targetArea(for: win) else {
        log("ERROR: no screen found")
        return
    }
    guard axSize(win) != nil else {
        log("ERROR: window has no size")
        return
    }

    let target = box(in: area)
    var actual = target.size

    // Move to the target origin before resizing: macOS clamps a resize to the
    // screen edge measured from the window's current origin, so growing a window
    // that still sits further down the screen silently truncates it.
    if grid != nil {
        var seed = target.origin
        axSet(win, kAXPositionAttribute as String, &seed)
    }

    let deadline = Date().addingTimeInterval(0.2)
    repeat {
        if grid != nil {
            var wanted = target.size
            axSet(win, kAXSizeAttribute as String, &wanted)
        }
        // Re-read the size each pass: it changes during the float transition, and
        // apps clamp the requested size to their own min/max. Centering whatever
        // we actually got keeps windows that refuse to resize centered in the
        // grid cell rather than pinned to its top-left corner.
        if let current = axSize(win) { actual = current }
        var origin = centered(actual, in: target)
        axSet(win, kAXPositionAttribute as String, &origin)
        usleep(2000)
    } while Date() < deadline

    log("placed \(actual.width)x\(actual.height) in \(target) within \(area)")
}

// ── Main ────────────────────────────────────────────────────────────

/// The window to act on, plus what AeroSpace knows about it. `id` and `layout`
/// are nil for windows AeroSpace does not manage (orphaned popups never appear
/// in list-windows).
struct Target {
    let element: AXUIElement
    let id: UInt32?
    let layout: String?
}

func resolveTarget() -> Target {
    // AeroSpace only exports AEROSPACE_WINDOW_ID to on-window-detected callbacks,
    // not to keybindings, so an explicit id is not always available.
    let env = ProcessInfo.processInfo.environment
    if let id = argWindowId ?? env["AEROSPACE_WINDOW_ID"].flatMap({ UInt32($0) }),
       let info = aeroWindow(id: id),
       let element = axWindow(pid: info.pid, id: id) {
        log("window \(id) pid=\(info.pid) layout=\(info.layout)")
        return Target(element: element, id: id, layout: info.layout)
    }

    // Otherwise go the other way: start from the window the user is actually
    // looking at and derive its id. AeroSpace's own notion of "focused" can lag
    // behind the macOS frontmost app when floating windows from other workspaces
    // are involved, and trusting it is what made the old helper move the wrong
    // window.
    guard let front = NSWorkspace.shared.frontmostApplication else {
        log("ERROR: no frontmost application")
        exit(0)
    }
    let axApp = AXUIElementCreateApplication(front.processIdentifier)
    guard let focused = axQueryWithRetry(axApp, kAXFocusedWindowAttribute as String) else {
        log("ERROR: no focused window for \(front.localizedName ?? "?")")
        exit(0)
    }
    let element = focused as! AXUIElement

    // Look the window up in AeroSpace anyway, so --toggle knows its layout. The
    // id is still worth keeping when the lookup misses: it keys --fullscreen's
    // saved frame, and orphaned popups never appear in list-windows.
    var wid: CGWindowID = 0
    let id: UInt32? = _AXUIElementGetWindow(element, &wid) == .success ? wid : nil
    let layout = id.flatMap { aeroWindow(id: $0)?.layout }
    log("frontmost \(front.localizedName ?? "?") -> window \(id.map(String.init) ?? "?") layout=\(layout ?? "unmanaged")")
    return Target(element: element, id: id, layout: layout)
}

// ── Fullscreen toggle ───────────────────────────────────────────────
// `aerospace fullscreen` silently does nothing to a floating window — it even
// reports success under --fail-if-noop — so there is no way back out of a
// maximized float using AeroSpace alone. Do it here instead, remembering the
// frame to restore.

struct Frame: Codable {
    var x, y, w, h: Double

    init(_ rect: CGRect) {
        x = rect.origin.x
        y = rect.origin.y
        w = rect.size.width
        h = rect.size.height
    }

    var rect: CGRect { CGRect(x: x, y: y, width: w, height: h) }
}

struct SavedFrame: Codable {
    /// Where the window was before it was maximized.
    var restore: Frame
    /// The frame the maximize actually achieved. Compared against on the next
    /// press instead of the requested frame, because apps with a max size never
    /// reach it — and then there would be no way back out, which is the bug this
    /// whole path exists to fix.
    var applied: Frame
}

let stateURL = FileManager.default.temporaryDirectory
    .appendingPathComponent("float-place-fullscreen.json")

func loadSavedFrames() -> [String: SavedFrame] {
    guard let data = try? Data(contentsOf: stateURL),
          let saved = try? JSONDecoder().decode([String: SavedFrame].self, from: data)
    else { return [:] }
    return saved
}

func storeSavedFrames(_ frames: [String: SavedFrame]) {
    guard let data = try? JSONEncoder().encode(frames) else { return }
    try? data.write(to: stateURL)
}

func matches(_ a: CGRect, _ b: CGRect) -> Bool {
    abs(a.minX - b.minX) < 2 && abs(a.minY - b.minY) < 2
        && abs(a.width - b.width) < 2 && abs(a.height - b.height) < 2
}

func axFrame(_ win: AXUIElement) -> CGRect? {
    guard let origin = axOrigin(win), let size = axSize(win) else { return nil }
    return CGRect(origin: origin, size: size)
}

/// Move and resize a window, returning the frame actually achieved.
///
/// Position is set before size, and again afterwards: macOS clamps a resize to
/// the screen edge measured from the window's *current* origin, so growing a
/// window that still sits further down the screen silently truncates it.
@discardableResult
func applyFrame(_ win: AXUIElement, _ rect: CGRect) -> CGRect {
    var achieved = rect
    let deadline = Date().addingTimeInterval(0.15)
    repeat {
        var origin = rect.origin
        var size = rect.size
        axSet(win, kAXPositionAttribute as String, &origin)
        axSet(win, kAXSizeAttribute as String, &size)
        axSet(win, kAXPositionAttribute as String, &origin)
        if let current = axFrame(win) {
            achieved = current
            if matches(current, rect) { break }
        }
        usleep(5000)
    } while Date() < deadline
    return achieved
}

func toggleFullscreen(_ target: Target) {
    // Tiling windows already work, and AeroSpace needs to stay the source of
    // truth for anything in its tree.
    if let layout = target.layout, layout != "floating" {
        var args = ["fullscreen"]
        if let id = target.id {
            args.append("--window-id")
            args.append(String(id))
        }
        _ = runAero(args)
        log("delegated fullscreen to AeroSpace")
        return
    }

    guard let area = targetArea(for: target.element), let current = axFrame(target.element) else {
        log("ERROR: could not read window geometry")
        return
    }

    let key = target.id.map(String.init) ?? "frontmost"
    var frames = loadSavedFrames()

    // Only restore if the window is still where the maximize left it. Window ids
    // get recycled and the user may have moved the window since, so a stale entry
    // must not teleport it somewhere unexpected.
    if let saved = frames[key], matches(current, saved.applied.rect) {
        let achieved = applyFrame(target.element, saved.restore.rect)
        frames[key] = nil
        storeSavedFrames(frames)
        log("restored to \(achieved)")
        return
    }

    let achieved = applyFrame(target.element, area)
    frames[key] = SavedFrame(restore: Frame(current), applied: Frame(achieved))
    storeSavedFrames(frames)
    log("maximized to \(achieved) (asked for \(area))")
}

func setLayout(_ target: String, windowId: UInt32?) {
    var args = ["layout", target]
    if let id = windowId {
        args.append("--window-id")
        args.append(String(id))
    }
    _ = runAero(args)
}

func run() {
    let target = resolveTarget()
    let isFloating = target.layout == "floating"

    if fullscreen {
        toggleFullscreen(target)
        return
    }

    if toggle {
        if isFloating {
            // Hand the window back to the tiling tree. Synchronous, so AeroSpace's
            // tree stays consistent — an async toggle used to orphan the window.
            setLayout("tiling", windowId: target.id)
            log("toggled back to tiling")
            return
        }
        if target.layout != nil {
            setLayout("floating", windowId: target.id)
            usleep(300_000) // let AeroSpace settle the float before touching geometry
        }
        // A nil layout means AeroSpace never managed it: it is already free-floating.
    } else if ifFloating && !isFloating {
        log("not floating, skipping")
        return
    }

    place(target.element)
}

run()
