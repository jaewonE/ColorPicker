import AppKit
import SwiftUI

@main
struct ColorPickerApplication: App {
    @NSApplicationDelegateAdaptor(ColorPickerAppDelegate.self) private var appDelegate
    @StateObject private var sampler = ScreenSampler()

    var body: some Scene {
        WindowGroup("ColorPicker") {
            ContentView(sampler: sampler)
                .task { sampler.start() }
                .onReceive(NotificationCenter.default.publisher(for: .toggleCoordinateLock)) { _ in
                    sampler.toggleCoordinateLock()
                }
                .onReceive(NotificationCenter.default.publisher(for: .saveCurrentColor)) { _ in
                    sampler.saveCurrentColor()
                }
        }
        .defaultSize(width: 368, height: 188)
        .windowResizability(.contentSize)
        .commands {
            CommandMenu("ColorPicker") {
                Button(sampler.isPositionLocked ? "Unlock Coordinate" : "Lock Coordinate") {
                    sampler.toggleCoordinateLock()
                }
                Button("Save Current Color to Clipboard") {
                    sampler.saveCurrentColor()
                }
            }
        }
    }
}

final class ColorPickerAppDelegate: NSObject, NSApplicationDelegate {
    private let hotKeys = GlobalHotKeyManager()

    func applicationDidFinishLaunching(_ notification: Notification) {
        hotKeys.install()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}

extension Notification.Name {
    static let toggleCoordinateLock = Notification.Name("ColorPicker.toggleCoordinateLock")
    static let saveCurrentColor = Notification.Name("ColorPicker.saveCurrentColor")
}
