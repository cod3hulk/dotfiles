// Center the focused window on its current monitor's visible area.
// Handles the full float-toggle + center cycle itself to eliminate the
// visible "jump to corner" that happens when AeroSpace places a newly-floated
// window at a default position before a separate script repositions it.
//
// Strategy: launch `aerospace layout floating` asynchronously (don't wait),
// then immediately set the centered position via AX API in a tight loop
// for ~300ms. No matter when AeroSpace sets its default position, we
// overwrite it within microseconds — faster than a single render frame
// (~16ms at 60fps), so the corner position is never visible.
//
// Build: swiftc -O center-window.swift -o center-window
// Usage from aerospace.toml: exec-and-forget /path/to/center-window

import AppKit
import ApplicationServices
import Foundation

let aerospace = "/opt/homebrew/bin/aerospace"
let logFile = "/tmp/center-window.log"

func log(_ msg: String) {
    let ts = DateFormatter()
    ts.dateFormat = "HH:mm:ss.SSS"
    let line = "[\(ts.string(from: Date()))] \(msg)\n"
    let url = URL(fileURLWithPath: logFile)
    // Create the file if it doesn't exist yet
    if !FileManager.default.fileExists(atPath: logFile) {
        FileManager.default.createFile(atPath: logFile, contents: nil)
    }
    if let handle = try? FileHandle(forWritingTo: url) {
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

// 1. Get current layout and focused window info from AeroSpace.
//    Use AeroSpace's notion of "focused" (not NSWorkspace's "frontmost")
//    because they can differ — especially right after workspace switches
//    or when triggered via a hotkey while an app is mid-transition.
let layout = runAero(["list-windows", "--focused", "--format", "%{window-layout}"])
let focusedInfo = runAero(["list-windows", "--focused", "--format", "%{app-pid}"])

log("layout='\(layout)' focusedInfo='\(focusedInfo)'")

// 2. If already floating → toggle back to tiling, done.
if layout == "floating" {
    _ = runAero(["layout", "tiling"])
    log("toggled back to tiling")
    exit(0)
}

// 3. Get the focused window via AX API.
//    Prefer the PID from AeroSpace (authoritative for which window is
//    actually focused in the WM). Fall back to NSWorkspace.frontmostApplication
//    only if AeroSpace doesn't return a PID.
var pid: pid_t = 0
if let pidVal = Int32(focusedInfo) {
    pid = pid_t(pidVal)
} else if let frontApp = NSWorkspace.shared.frontmostApplication {
    pid = frontApp.processIdentifier
} else {
    log("ERROR: no focused window — neither AeroSpace nor NSWorkspace returned a PID")
    exit(0)
}

let axApp = AXUIElementCreateApplication(pid)

// Retry AX queries — some apps (notably Alacritty) can be slow to respond,
// especially under load. Try up to 5 times with 50ms between attempts.
func axQueryWithRetry(_ element: AXUIElement, _ attr: String, _ retries: Int = 5) -> CFTypeRef? {
    var ref: CFTypeRef?
    for attempt in 0..<retries {
        let result = AXUIElementCopyAttributeValue(element, attr as CFString, &ref)
        if result == .success && ref != nil {
            return ref
        }
        log("AX query '\(attr)' attempt \(attempt + 1)/\(retries) failed: \(result.rawValue)")
        usleep(50_000) // 50ms
    }
    return nil
}

guard let window = axQueryWithRetry(axApp, kAXFocusedWindowAttribute as String) else {
    log("ERROR: could not get focused window via AX for pid=\(pid)")
    exit(0)
}
let winElement = window as! AXUIElement

// Get current size (position will change when floated, size stays)
guard let sizeVal = axQueryWithRetry(winElement, kAXSizeAttribute as String) else {
    log("ERROR: could not get window size via AX for pid=\(pid)")
    exit(0)
}

var size = CGSize.zero
AXValueGetValue(sizeVal as! AXValue, .cgSize, &size)

// 4. Find which screen contains the window center (using current/tiled position)
var pos = CGPoint.zero
if let posVal = axQueryWithRetry(winElement, kAXPositionAttribute as String) {
    AXValueGetValue(posVal as! AXValue, .cgPoint, &pos)
}

let winCx = pos.x + size.width / 2
let winCy = pos.y + size.height / 2

let screens = NSScreen.screens
guard let primaryScreen = screens.first else {
    log("ERROR: no screens found")
    exit(0)
}
let primaryHeight = primaryScreen.frame.size.height

var targetScreen: NSScreen? = nil
for screen in screens {
    let f = screen.frame
    let screenTop = primaryHeight - (f.origin.y + f.size.height)
    let screenLeft = f.origin.x
    if winCx >= screenLeft && winCx <= screenLeft + f.size.width &&
       winCy >= screenTop && winCy <= screenTop + f.size.height {
        targetScreen = screen
        break
    }
}

let screen = targetScreen ?? primaryScreen
let vf = screen.visibleFrame
let vfTop = primaryHeight - (vf.origin.y + vf.size.height)
let vfLeft = vf.origin.x

log("window size=\(size.width)x\(size.height) screen=\(screen.localizedName) vf=\(vf.width)x\(vf.height)")

// 5. Launch `aerospace layout floating` asynchronously — don't wait for it.
//    AeroSpace will float the window and place it at a default corner position,
//    but we won't wait for that to happen.
let floatTask = Process()
floatTask.executableURL = URL(fileURLWithPath: aerospace)
floatTask.arguments = ["layout", "floating"]
floatTask.standardOutput = Pipe()
floatTask.standardError = Pipe()
try? floatTask.run()

// 6. Hammer the position to center in a tight loop for ~300ms.
//    Re-read the window size each iteration and recompute the centered
//    position, so that if AeroSpace or the app changes the size during
//    the float transition, we still center correctly with equal margins
//    on all sides.
let deadline = Date().addingTimeInterval(0.3)
while Date() < deadline {
    // Re-read current size (may change when floated)
    if let curSizeVal = axQueryWithRetry(winElement, kAXSizeAttribute as String, 2) {
        var curSize = CGSize.zero
        AXValueGetValue(curSizeVal as! AXValue, .cgSize, &curSize)
        if curSize.width > 0 && curSize.height > 0 {
            size = curSize
        }
    }
    // Recompute centered position with current size
    let cx = vfLeft + (vf.size.width - size.width) / 2
    let cy = vfTop + (vf.size.height - size.height) / 2
    var curPos = CGPoint(x: cx, y: cy)
    let curPosVal = AXValueCreate(.cgPoint, &curPos)!
    AXUIElementSetAttributeValue(winElement, kAXPositionAttribute as CFString, curPosVal as CFTypeRef)
    // Tiny yield to avoid pegging CPU, but much shorter than a render frame
    usleep(500) // 0.5ms
}

// 7. Wait for the float task to finish (should already be done)
floatTask.waitUntilExit()

// 8. Final re-read + position set to be absolutely sure
if let finalSizeVal = axQueryWithRetry(winElement, kAXSizeAttribute as String, 3) {
    var finalSize = CGSize.zero
    AXValueGetValue(finalSizeVal as! AXValue, .cgSize, &finalSize)
    if finalSize.width > 0 && finalSize.height > 0 {
        size = finalSize
    }
}
let finalX = vfLeft + (vf.size.width - size.width) / 2
let finalY = vfTop + (vf.size.height - size.height) / 2
var finalPos = CGPoint(x: finalX, y: finalY)
let finalPosVal = AXValueCreate(.cgPoint, &finalPos)!
AXUIElementSetAttributeValue(winElement, kAXPositionAttribute as CFString, finalPosVal as CFTypeRef)

log("done — centered at (\(finalX), \(finalY)) size=\(size.width)x\(size.height)")
