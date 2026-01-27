import SwiftUI
import AppKit
import Combine

/// Manages persistent settings for the Holster app
class AppSettings: ObservableObject {
    static let shared = AppSettings()
    
    @AppStorage("targetBundleID") var targetBundleID: String = ""
    @AppStorage("targetAppPath") var targetAppPath: String = ""
    @AppStorage("targetAppName") var targetAppName: String = ""
    
    /// Returns true if an app is configured
    var hasTargetApp: Bool {
        return !targetAppPath.isEmpty
    }
    
    /// Updates the target app from a URL (typically from NSOpenPanel)
    /// Returns true if successful, false if app couldn't be configured
    func setTargetApp(from url: URL) -> Bool {
        let bundle = Bundle(url: url)
        
        // Validate it's a real app
        guard FileManager.default.fileExists(atPath: url.path) else {
            print("[Holster] Error: App does not exist at path: \(url.path)")
            return false
        }
        
        targetBundleID = bundle?.bundleIdentifier ?? ""
        targetAppPath = url.path
        
        // Get the proper display name that macOS uses for window detection
        if let bundle = bundle,
           let displayName = bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String {
            targetAppName = displayName
        } else if let bundle = bundle,
                  let bundleName = bundle.object(forInfoDictionaryKey: "CFBundleName") as? String {
            targetAppName = bundleName
        } else {
            targetAppName = url.deletingPathExtension().lastPathComponent
        }
        
        print("[Holster] Selected app: \(targetAppName), bundleID: \(targetBundleID), path: \(targetAppPath)")
        
        objectWillChange.send()
        NotificationCenter.default.post(name: .targetAppChanged, object: nil)
        
        return true
    }
    
    /// Clears the target app
    func clearTargetApp() {
        targetBundleID = ""
        targetAppPath = ""
        targetAppName = ""
        
        objectWillChange.send()
        NotificationCenter.default.post(name: .targetAppChanged, object: nil)
    }
    
    /// Gets the icon for the currently selected app
    /// Size defaults to the system menu bar height minus padding for proper fit
    func getAppIcon(size: NSSize? = nil) -> NSImage {
        // Calculate appropriate size based on menu bar, with padding
        let menuBarHeight = NSStatusBar.system.thickness
        let iconSize = size ?? NSSize(width: menuBarHeight - 4, height: menuBarHeight - 4)
        if hasTargetApp {
            // Holstered app icon - keep full color, no template
            let icon = NSWorkspace.shared.icon(forFile: targetAppPath)
            icon.size = iconSize
            return icon
        } else {
            // Return the custom menu bar icon (template) when no app is set
            if let originalIcon = NSImage(named: "MenuBarIcon") {
                // Create a new image at the exact size to prevent any resizing
                let icon = NSImage(size: iconSize)
                icon.addRepresentation(NSBitmapImageRep(
                    bitmapDataPlanes: nil,
                    pixelsWide: Int(iconSize.width * 2),  // @2x for retina
                    pixelsHigh: Int(iconSize.height * 2),
                    bitsPerSample: 8,
                    samplesPerPixel: 4,
                    hasAlpha: true,
                    isPlanar: false,
                    colorSpaceName: .deviceRGB,
                    bytesPerRow: 0,
                    bitsPerPixel: 0
                )!)
                icon.lockFocus()
                originalIcon.draw(in: NSRect(origin: .zero, size: iconSize),
                                  from: NSRect(origin: .zero, size: originalIcon.size),
                                  operation: .copy,
                                  fraction: 1.0)
                icon.unlockFocus()
                icon.isTemplate = true
                return icon
            }
            // Fallback
            let icon = NSApp.applicationIconImage ?? NSImage(systemSymbolName: "app", accessibilityDescription: "App")!
            icon.size = iconSize
            icon.isTemplate = true
            return icon
        }
    }
}

// MARK: - Notification Extension
extension Notification.Name {
    static let targetAppChanged = Notification.Name("targetAppChanged")
}
