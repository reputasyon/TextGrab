import SwiftUI
import Combine

@Observable
final class ShortcutState {
    var ocrLabel: String = PreferencesManager.shared.shortcutDisplayString
    var ssLabel: String = PreferencesManager.shared.ssDisplayString
    private var cancellable: AnyCancellable?

    init() {
        cancellable = NotificationCenter.default
            .publisher(for: .shortcutDidChange)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.ocrLabel = PreferencesManager.shared.shortcutDisplayString
                self?.ssLabel = PreferencesManager.shared.ssDisplayString
            }
    }
}

@main
struct TextGrabApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @State private var shortcutState = ShortcutState()

    var body: some Scene {
        MenuBarExtra("TextGrab", systemImage: "text.viewfinder") {
            Button("\(L.captureText) (\(shortcutState.ocrLabel))") {
                CaptureCoordinator.shared.startCapture(mode: .ocr)
            }

            Button("\(L.captureScreenshot) (\(shortcutState.ssLabel))") {
                CaptureCoordinator.shared.startCapture(mode: .screenshot)
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

        // OCR hotkey
        HotkeyManager.shared.register(
            keyCode: prefs.keyCode,
            modifiers: prefs.modifiers
        ) {
            CaptureCoordinator.shared.startCapture(mode: .ocr)
        }

        // Screenshot hotkey
        HotkeyManager.shared.registerScreenshot(
            keyCode: prefs.ssKeyCode,
            modifiers: prefs.ssModifiers
        ) {
            CaptureCoordinator.shared.startCapture(mode: .screenshot)
        }

        WelcomeWindow.showIfNeeded()
    }
}
