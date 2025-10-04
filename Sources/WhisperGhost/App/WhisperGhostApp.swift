import AppKit
import SwiftUI

@main
struct WhisperGhostApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var audioManager = AudioRecorderManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(audioManager)
                .frame(minWidth: 300, minHeight: 250)
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {

    var overlayWindow: OverlayWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        configureAppearance()
        activateAndCenterWindow()
        showOverlay()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    private func configureAppearance() {
        NSApp.setActivationPolicy(.regular)
    }

    private func activateAndCenterWindow() {
        NSApp.activate(ignoringOtherApps: true)

        if let window = NSApplication.shared.windows.first {
            window.makeKeyAndOrderFront(nil)
            window.center()
        }
    }

    private func showOverlay() {
        overlayWindow = OverlayWindow()
        overlayWindow?.makeKeyAndOrderFront(nil)
    }
}
