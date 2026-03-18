import SwiftUI
import Carbon
import AppKit

struct SettingsView: View {
    @State private var currentShortcut: String = PreferencesManager.shared.shortcutDisplayString
    @State private var isRecording = false
    @State private var localMonitor: Any?
    @State private var flagsMonitor: Any?

    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack(spacing: 10) {
                Image(systemName: "text.viewfinder")
                    .font(.system(size: 28))
                    .foregroundStyle(.secondary)
                Text("TextGrab Ayarlar")
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            .padding(.top, 4)

            Divider()

            // Shortcut section
            VStack(alignment: .leading, spacing: 12) {
                Text("Klavye Kısayolu")
                    .font(.headline)

                Text("Ekrandan metin yakalama kısayolunu ayarlayın.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 16) {
                    Text("Kısayol:")
                        .frame(width: 60, alignment: .trailing)

                    // Shortcut display / recorder button
                    Button(action: {
                        toggleRecording()
                    }) {
                        HStack(spacing: 8) {
                            if isRecording {
                                Image(systemName: "record.circle")
                                    .foregroundStyle(.red)
                                Text("Bir tuş kombinasyonu girin...")
                                    .foregroundStyle(.secondary)
                            } else {
                                Text(currentShortcut)
                                    .font(.system(size: 15, weight: .medium, design: .rounded))
                            }
                        }
                        .frame(minWidth: 180, minHeight: 28)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(isRecording
                                      ? Color.red.opacity(0.08)
                                      : Color(nsColor: .controlBackgroundColor))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isRecording ? Color.red.opacity(0.5) : Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)

                    if isRecording {
                        Button("İptal") {
                            stopRecording()
                        }
                        .controlSize(.small)
                    }
                }

                if isRecording {
                    Text("Kaydetmek istediğiniz tuş kombinasyonuna basın. ESC ile iptal edin.")
                        .font(.caption)
                        .foregroundStyle(.orange)
                        .padding(.leading, 76)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)

            Divider()

            // Bottom buttons
            HStack {
                Button("Varsayılana Sıfırla") {
                    resetToDefault()
                }
                .disabled(PreferencesManager.shared.isDefault && !isRecording)

                Spacer()

                Button("Kapat") {
                    stopRecording()
                    NSApp.keyWindow?.close()
                }
                .keyboardShortcut(.cancelAction)
            }
            .padding(.horizontal)

            Divider()

            // Footer
            HStack(spacing: 6) {
                Text("Made by")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                LinkButton(title: "@reputasyon", url: "https://github.com/reputasyon")

                Spacer()

                LinkButton(
                    title: "GitHub'da Star Ver",
                    url: "https://github.com/reputasyon/TextGrab",
                    icon: "star.fill",
                    tint: .orange
                )
            }
            .padding(.horizontal)
            .padding(.bottom, 4)
        }
        .padding(20)
        .frame(width: 440, height: 320)
        .onDisappear {
            stopRecording()
        }
    }

    // MARK: - Recording

    private func toggleRecording() {
        if isRecording {
            stopRecording()
        } else {
            startRecording()
        }
    }

    private func startRecording() {
        isRecording = true

        // Temporarily unregister the global hotkey so it doesn't fire while recording
        HotkeyManager.shared.unregister()

        // Monitor key events locally in this window
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if event.keyCode == 53 { // Escape - cancel
                self.stopRecording()
                return nil
            }

            let carbonMods = PreferencesManager.carbonModifiers(from: event.modifierFlags)

            // Require at least one modifier key
            if carbonMods == 0 {
                return nil
            }

            let keyCode = UInt32(event.keyCode)

            // Save the new shortcut
            PreferencesManager.shared.keyCode = keyCode
            PreferencesManager.shared.modifiers = carbonMods
            self.currentShortcut = PreferencesManager.shared.shortcutDisplayString

            // Re-register with new shortcut
            HotkeyManager.shared.register(
                keyCode: keyCode,
                modifiers: carbonMods
            ) {
                CaptureCoordinator.shared.startCapture()
            }

            self.isRecording = false
            self.removeMonitors()

            // Post notification for menu update
            NotificationCenter.default.post(name: .shortcutDidChange, object: nil)

            return nil
        }
    }

    private func stopRecording() {
        guard isRecording else { return }
        isRecording = false
        removeMonitors()

        // Re-register the saved hotkey
        let prefs = PreferencesManager.shared
        HotkeyManager.shared.register(
            keyCode: prefs.keyCode,
            modifiers: prefs.modifiers
        ) {
            CaptureCoordinator.shared.startCapture()
        }
    }

    private func removeMonitors() {
        if let monitor = localMonitor {
            NSEvent.removeMonitor(monitor)
            localMonitor = nil
        }
        if let monitor = flagsMonitor {
            NSEvent.removeMonitor(monitor)
            flagsMonitor = nil
        }
    }

    private func resetToDefault() {
        stopRecording()
        PreferencesManager.shared.resetToDefaults()
        currentShortcut = PreferencesManager.shared.shortcutDisplayString

        // Re-register default hotkey
        HotkeyManager.shared.register(
            keyCode: PreferencesManager.defaultKeyCode,
            modifiers: PreferencesManager.defaultModifiers
        ) {
            CaptureCoordinator.shared.startCapture()
        }

        NotificationCenter.default.post(name: .shortcutDidChange, object: nil)
    }
}

// MARK: - Link Button

struct LinkButton: View {
    let title: String
    let url: String
    var icon: String? = nil
    var tint: Color = .blue

    var body: some View {
        Button {
            if let link = URL(string: url) {
                NSWorkspace.shared.open(link)
            }
        } label: {
            HStack(spacing: 4) {
                if let icon {
                    Image(systemName: icon)
                        .font(.caption2)
                        .foregroundStyle(tint)
                }
                Text(title)
                    .font(.caption2)
            }
            .foregroundStyle(tint.opacity(0.8))
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            if hovering { NSCursor.pointingHand.push() } else { NSCursor.pop() }
        }
    }
}

// MARK: - Notification

extension Notification.Name {
    static let shortcutDidChange = Notification.Name("shortcutDidChange")
}

// MARK: - Settings Window Controller

enum SettingsWindowController {
    private static var window: NSWindow?

    @MainActor
    static func show() {
        if let existing = window, existing.isVisible {
            existing.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let settingsView = SettingsView()
        let hostingView = NSHostingView(rootView: settingsView)

        let newWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 440, height: 320),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        newWindow.title = "TextGrab Ayarlar"
        newWindow.contentView = hostingView
        newWindow.center()
        newWindow.isReleasedWhenClosed = false
        newWindow.level = .floating

        window = newWindow
        newWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
