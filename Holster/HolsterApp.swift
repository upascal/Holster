import SwiftUI
import AppKit
import CoreGraphics
import UniformTypeIdentifiers

@main
struct HolsterApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            SettingsView()
        }
    }
}

// MARK: - Settings View
struct SettingsView: View {
    @ObservedObject private var settings = AppSettings.shared
    @State private var appIcon: NSImage = AppSettings.shared.getAppIcon(size: NSSize(width: 32, height: 32))
    @State private var statusMessage: String = ""
    @State private var isSuccess: Bool = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            GroupBox("About") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Holster")
                        .font(.headline)
                    Text("A menu bar app to quickly toggle any application.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            GroupBox("Target Application") {
                VStack(alignment: .leading, spacing: 12) {
                    if settings.hasTargetApp {
                        // App is configured
                        HStack(spacing: 12) {
                            Image(nsImage: appIcon)
                                .resizable()
                                .frame(width: 32, height: 32)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(settings.targetAppName)
                                    .font(.headline)
                                Text(settings.targetAppPath)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                            }
                            
                            Spacer()
                        }
                    } else {
                        // Empty state
                        HStack(spacing: 12) {
                            Image(nsImage: appIcon)
                                .resizable()
                                .frame(width: 32, height: 32)
                                .opacity(0.5)
                            
                            Text("No app selected")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                        }
                    }
                    
                    HStack(spacing: 8) {
                        Button(settings.hasTargetApp ? "Change App..." : "Choose App...") {
                            chooseApplication()
                        }
                        .buttonStyle(.borderedProminent)
                        
                        if settings.hasTargetApp {
                            Button("Clear") {
                                settings.clearTargetApp()
                                updateIcon()
                                statusMessage = "App cleared"
                                isSuccess = true
                            }
                            .foregroundColor(.secondary)
                        }
                    }
                    
                    // Status message
                    if !statusMessage.isEmpty {
                        Text(statusMessage)
                            .font(.caption)
                            .foregroundColor(isSuccess ? .green : .red)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            if settings.hasTargetApp {
                GroupBox("Usage") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "cursorarrow.click")
                            Text("Left-click: Toggle \(settings.targetAppName) on/off")
                        }
                        HStack {
                            Image(systemName: "cursorarrow.click.2")
                            Text("Right-click: Show menu")
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            
            Spacer()
        }
        .padding()
        .frame(width: 350, height: settings.hasTargetApp ? 320 : 240)
        .onReceive(NotificationCenter.default.publisher(for: .targetAppChanged)) { _ in
            updateIcon()
        }
    }
    
    private func chooseApplication() {
        let panel = NSOpenPanel()
        panel.title = "Choose Application"
        panel.allowedContentTypes = [.application]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.directoryURL = URL(fileURLWithPath: "/Applications")
        
        if panel.runModal() == .OK, let url = panel.url {
            if settings.setTargetApp(from: url) {
                statusMessage = "✓ \(settings.targetAppName) is now your holstered app"
                isSuccess = true
            } else {
                statusMessage = "✗ Failed to set app"
                isSuccess = false
            }
            updateIcon()
        }
    }
    
    private func updateIcon() {
        appIcon = settings.getAppIcon(size: NSSize(width: 32, height: 32))
    }
}

// MARK: - App Delegate
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var settingsWindow: NSWindow?
    private let settings = AppSettings.shared
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide the app from the Dock since it's a menu bar only app
        NSApp.setActivationPolicy(.accessory)
        
        // Create the status bar item with fixed square length (standard menu bar size)
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        setupStatusButton()
        
        // Listen for app changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(targetAppDidChange),
            name: .targetAppChanged,
            object: nil
        )
    }
    
    private func setupStatusButton() {
        if let button = statusItem?.button {
            let icon = settings.getAppIcon()
            button.image = icon
            button.imageScaling = .scaleProportionallyDown
            button.imagePosition = .imageOnly
            button.isBordered = false
            if settings.hasTargetApp {
                button.toolTip = "Click to toggle \(settings.targetAppName) • Right-click for options"
            } else {
                button.toolTip = "Click to choose an app • Right-click for options"
            }
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            button.action = #selector(handleClick)
            button.target = self
        }
    }
    
    @objc func targetAppDidChange() {
        setupStatusButton()
    }
    
    @objc func handleClick(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!
        
        if event.type == .rightMouseUp {
            showMenu()
        } else {
            // If no app is set, open settings instead of toggling
            if settings.hasTargetApp {
                toggleApp()
            } else {
                openSettings()
            }
        }
    }
    
    // MARK: - Menu
    private func showMenu() {
        let menu = NSMenu()
        
        if settings.hasTargetApp {
            let appName = settings.targetAppName
            
            // Show/Hide App
            let showItem = NSMenuItem(title: "Show \(appName)", action: #selector(showApp), keyEquivalent: "")
            showItem.target = self
            menu.addItem(showItem)
            
            let hideItem = NSMenuItem(title: "Hide \(appName)", action: #selector(hideApp), keyEquivalent: "")
            hideItem.target = self
            menu.addItem(hideItem)
            
            menu.addItem(NSMenuItem.separator())
        }
        
        // Choose App (instead of Settings)
        let chooseAppItem = NSMenuItem(title: "Choose App...", action: #selector(openSettings), keyEquivalent: ",")
        chooseAppItem.target = self
        menu.addItem(chooseAppItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Quit
        let quitItem = NSMenuItem(title: "Quit Holster", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        // Show the menu
        statusItem?.menu = menu
        statusItem?.button?.performClick(nil)
        statusItem?.menu = nil
    }
    
    // MARK: - Actions
    @objc func showApp() {
        let url = URL(fileURLWithPath: settings.targetAppPath)
        NSWorkspace.shared.open(url)
    }
    
    @objc func hideApp() {
        guard let app = getTargetApp() else { return }
        app.hide()
    }
    
    @objc func openSettings() {
        if settingsWindow == nil {
            let settingsView = SettingsView()
            let hostingController = NSHostingController(rootView: settingsView)
            let window = NSWindow(contentViewController: hostingController)
            window.title = "Holster Settings"
            window.styleMask = [.titled, .closable]
            window.center()
            settingsWindow = window
        }
        
        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc func quit() {
        NSApplication.shared.terminate(nil)
    }
    
    // MARK: - App Detection
    
    private func getTargetApp() -> NSRunningApplication? {
        // First try by bundle ID (fastest)
        if !settings.targetBundleID.isEmpty {
            if let app = NSRunningApplication.runningApplications(withBundleIdentifier: settings.targetBundleID).first {
                return app
            }
        }
        
        // Fallback: find by matching the app URL/path
        let targetURL = URL(fileURLWithPath: settings.targetAppPath)
        for app in NSWorkspace.shared.runningApplications {
            if app.bundleURL == targetURL {
                return app
            }
        }
        
        return nil
    }
    
    // Fast native check for visible windows using Core Graphics
    private func appHasVisibleWindows() -> Bool {
        guard let runningApp = getTargetApp() else {
            return false
        }
        
        let appPID = runningApp.processIdentifier
        let appName = runningApp.localizedName ?? ""
        
        guard let windowList = CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID) as? [[String: Any]] else {
            return false
        }
        
        // Check both by name AND by PID (Adobe apps often have mismatched names)
        return windowList.contains { info in
            // Check by PID first (most reliable)
            if let ownerPID = info[kCGWindowOwnerPID as String] as? Int32, ownerPID == appPID {
                // Make sure it's a real window (has a name or is on-screen)
                if let layer = info[kCGWindowLayer as String] as? Int, layer == 0 {
                    return true
                }
            }
            // Fallback to name check
            if let ownerName = info[kCGWindowOwnerName as String] as? String, ownerName == appName {
                return true
            }
            return false
        }
    }
    
    // MARK: - Toggle Logic
    @objc func toggleApp() {
        guard let app = getTargetApp() else {
            // App not running - launch it
            print("[Holster] App not running, launching...")
            launchApp()
            return
        }
        
        print("[Holster] App state - isActive: \(app.isActive), isHidden: \(app.isHidden), hasWindows: \(appHasVisibleWindows())")
        
        // Fast logic with native window check:
        // - Only hide if app is frontmost AND has visible windows
        // - Otherwise open/show (NSWorkspace.open handles everything)
        if app.isActive && !app.isHidden && appHasVisibleWindows() {
            // App is frontmost with visible windows - hide it
            print("[Holster] Hiding app...")
            let success = app.hide()
            print("[Holster] Hide result: \(success)")
            
            // Some apps (like Adobe) need a moment - if hide failed, try activating ourselves first
            if !success {
                print("[Holster] Hide failed, trying alternate method...")
                NSApp.activate(ignoringOtherApps: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    _ = app.hide()
                }
            }
        } else {
            // Any other state - just open the app (fast, creates window if needed)
            print("[Holster] Showing app...")
            let url = URL(fileURLWithPath: self.settings.targetAppPath)
            NSWorkspace.shared.open(url)
        }
    }
    
    private func launchApp() {
        let config = NSWorkspace.OpenConfiguration()
        config.activates = true
        
        let url = URL(fileURLWithPath: settings.targetAppPath)
        NSWorkspace.shared.openApplication(at: url, configuration: config) { _, error in
            if let error = error {
                print("Failed to launch \(self.settings.targetAppName): \(error.localizedDescription)")
            }
        }
    }
}
