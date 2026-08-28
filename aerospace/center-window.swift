// Center the focused window on its current monitor's visible area.
// Handles the full float-toggle + center cycle.
//
// IMPORTANT: We use NSWorkspace.shared.frontmostApplication (not AeroSpace's
// "focused" window) for AX operations, because AeroSpace's focused window can
// differ from the macOS frontmost app when floating windows from other
// workspaces are involved.
//
// The float/tiling toggle is done via synchronous `aerospace layout` commands
// (NOT async) to ensure AeroSpace's window tree stays consistent. AX position
// hammering is done AFTER the float completes, only for centering.
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

func centerWindow(_ winElement: AXUIElement, _ vf: CGRect, _ primaryHeight: CGFloat) {
    // Get current size
    var size = CGSize.zero
    if let sizeVal = axQueryWithRetry(winElement, kAXSizeAttribute as String) {
        AXValueGetValue(sizeVal as! AXValue, .cgSize, &size)
    }
    guard size.width > 0 && size.height > 0 else { return }

    let vfTop = primaryHeight - (vf.origin.y + vf.size.height)
    let vfLeft = vf.origin.x

    // Hammer the position for ~200ms to ensure it sticks
    let deadline = Date().addingTimeInterval(0.2)
    while Date() < deadline {
        // Re-read size each iteration (may change during transition)
        if let curSizeVal = axQueryWithRetry(winElement, kAXSizeAttribute as String, 2) {
            var curSize = CGSize.zero
            AXValueGetValue(curSizeVal as! AXValue, .cgSize, &curSize)
            if curSize.width > 0 && curSize.height > 0 {
                size = curSize
            }
        }
        let cx = vfLeft + (vf.size.width - size.width) / 2
        let cy = vfTop + (vf.size.height - size.height) / 2
        var curPos = CGPoint(x: cx, y: cy)
        let curPosVal = AXValueCreate(.cgPoint, &curPos)!
        AXUIElementSetAttributeValue(winElement, kAXPositionAttribute as CFString, curPosVal as CFTypeRef)
        usleep(2000) // 2ms
    }
    log("centered at size=\(size.width)x\(size.height)")
}

// 1. Get the macOS frontmost app — this is the window the user actually sees.
guard let frontApp = NSWorkspace.shared.frontmostApplication else {
    log("ERROR: no frontmost application")
    exit(0)
}
let pid = frontApp.processIdentifier
log("frontmost: \(frontApp.localizedName ?? "?") pid=\(pid)")

// 2. Get the frontmost app's window via AX API.
let axApp = AXUIElementCreateApplication(pid)
guard let window = axQueryWithRetry(axApp, kAXFocusedWindowAttribute as String) else {
    log("ERROR: could not get focused window via AX for pid=\(pid)")
    exit(0)
}
let winElement = window as! AXUIElement

// 3. Find which screen contains the window center.
var pos = CGPoint.zero
var size = CGSize.zero
if let posVal = axQueryWithRetry(winElement, kAXPositionAttribute as String) {
    AXValueGetValue(posVal as! AXValue, .cgPoint, &pos)
}
if let sizeVal = axQueryWithRetry(winElement, kAXSizeAttribute as String) {
    AXValueGetValue(sizeVal as! AXValue, .cgSize, &size)
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

// 4. Check if the window is managed by AeroSpace and its layout.
let aeroWindows = runAero(["list-windows", "--all", "--format", "%{app-pid} %{window-layout}"])
let aeroLines = aeroWindows.split(separator: "\n")
var isManagedByAero = false
var aeroLayout = ""
for line in aeroLines {
    let parts = line.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
    if parts.count >= 2 && Int32(parts[0]) == Int32(pid) {
        isManagedByAero = true
        aeroLayout = String(parts[1])
        break
    }
}

log("isManagedByAero=\(isManagedByAero) aeroLayout='\(aeroLayout)' screen=\(screen.localizedName)")

// 5. Toggle logic:
//    a) Managed + floating → tile it (synchronous, stays in AeroSpace tree)
//    b) Managed + tiled → float it (synchronous), then center with AX
//    c) Unmanaged (orphaned) → already floating, just center with AX
if isManagedByAero && aeroLayout == "floating" {
    // Toggle back to tiling
    _ = runAero(["layout", "tiling"])
    log("toggled back to tiling")
    exit(0)
}

if isManagedByAero && aeroLayout != "floating" {
    // Float the window using AeroSpace's native command (synchronous)
    _ = runAero(["layout", "floating"])
    sleep(1) // Wait for AeroSpace to settle the float

    // Now center with AX
    centerWindow(winElement, vf, primaryHeight)
    log("done — floated and centered")
    exit(0)
}

// Unmanaged window — just center it with AX
log("window not managed by aerospace — centering with AX only")
centerWindow(winElement, vf, primaryHeight)
log("done — centered unmanaged window")
