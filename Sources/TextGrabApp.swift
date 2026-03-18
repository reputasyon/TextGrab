import SwiftUI
import Combine

@Observable
final class ShortcutState {
    var label: String = PreferencesManager.shared.shortcutDisplayString
    private var cancellable: AnyCancellable?

    init() {
        cancellable = NotificationCenter.default
            .publisher(for: .shortcutDidChange)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.label = PreferencesManager.shared.shortcutDisplayString
            }
    }
}

@main
struct TextGrabApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var shortcutState = ShortcutState()

    var body: some Scene {
        MenuBarExtra("TextGrab", systemImage: "text.viewfinder") {
            Button("\(L.captureText) (\(shortcutState.label))") {
                CaptureCoordinator.shared.startCapture()
            }

            Divider()

            Button(L.settings) {
                SettingsWindowController.show()
            }

            Button(L.starOnGitHub) {
                if let url = URL(string: "https://github.com/reputasyon/TextGrab") {
                    NSWorkspace.shared.open(url)
                }
            }

            Divider()

            Button(L.quit) {
                NSApp.terminate(nil)
            }
            .keyboardShortcut("q")
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        let prefs = PreferencesManager.shared
        HotkeyManager.shared.register(
            keyCode: prefs.keyCode,
            modifiers: prefs.modifiers
        ) {
            CaptureCoordinator.shared.startCapture()
        }

        WelcomeWindow.showIfNeeded()
    }
}
