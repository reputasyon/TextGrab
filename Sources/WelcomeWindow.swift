import SwiftUI
import AppKit

enum WelcomeWindow {
    private static let hasLaunchedKey = "hasLaunchedBefore"
    private static var window: NSWindow?

    static var isFirstLaunch: Bool {
        !UserDefaults.standard.bool(forKey: hasLaunchedKey)
    }

    @MainActor
    static func showIfNeeded() {
        guard isFirstLaunch else { return }
        UserDefaults.standard.set(true, forKey: hasLaunchedKey)

        // Small delay so menu bar icon renders first
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            show()
        }
    }

    @MainActor
    private static func show() {
        guard let screen = NSScreen.main else { return }

        let windowWidth: CGFloat = 360
        let windowHeight: CGFloat = 280

        // Position: top-right area, just below menu bar, near where the icon would be
        let x = screen.frame.maxX - windowWidth - 80
        let y = screen.frame.maxY - windowHeight - 36

        let hostingView = NSHostingView(rootView: WelcomeView(onDismiss: {
            dismiss()
        }))

        let panel = NSPanel(
            contentRect: NSRect(x: x, y: y, width: windowWidth, height: windowHeight),
            styleMask: [.titled, .closable, .fullSizeContentView, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.titlebarAppearsTransparent = true
        panel.titleVisibility = .hidden
        panel.isMovableByWindowBackground = true
        panel.level = .floating
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        panel.contentView = hostingView
        panel.isReleasedWhenClosed = false

        window = panel
        panel.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @MainActor
    static func dismiss() {
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = 0.25
            window?.animator().alphaValue = 0
        }, completionHandler: {
            window?.orderOut(nil)
            window = nil
        })
    }
}

// MARK: - Welcome View

private struct WelcomeView: View {
    let onDismiss: () -> Void

    @State private var appeared = false

    var body: some View {
        VStack(spacing: 0) {
            // Arrow pointing to menu bar
            Triangle()
                .fill(Color(nsColor: .windowBackgroundColor))
                .frame(width: 20, height: 10)
                .offset(x: 100)

            VStack(spacing: 20) {
                // Icon + Title
                VStack(spacing: 10) {
                    Image(systemName: "text.viewfinder")
                        .font(.system(size: 40))
                        .foregroundStyle(.blue)
                        .symbolEffect(.bounce, value: appeared)

                    Text(L.welcomeTitle)
                        .font(.title2)
                        .fontWeight(.bold)

                    Text(L.welcomeSubtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                // Steps
                VStack(alignment: .leading, spacing: 12) {
                    StepRow(
                        number: "1",
                        icon: "command",
                        text: "**\(PreferencesManager.shared.shortcutDisplayString)** \(L.welcomeStep1)"
                    )
                    StepRow(
                        number: "2",
                        icon: "rectangle.dashed",
                        text: "\(L.welcomeStep2)"
                    )
                    StepRow(
                        number: "3",
                        icon: "doc.on.clipboard",
                        text: "\(L.welcomeStep3)"
                    )
                }
                .padding(.horizontal, 8)

                // CTA
                Button(action: onDismiss) {
                    Text(L.gotIt)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                // GitHub star
                HStack(spacing: 4) {
                    LinkButton(
                        title: L.starOnGitHub,
                        url: "https://github.com/reputasyon/TextGrab",
                        icon: "star.fill",
                        tint: .orange
                    )
                    Spacer()
                    Text("by")
                        .font(.caption2)
                        .foregroundStyle(.quaternary)
                    LinkButton(
                        title: "reputasyon",
                        url: "https://github.com/reputasyon"
                    )
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(nsColor: .windowBackgroundColor))
                    .shadow(color: .black.opacity(0.15), radius: 20, y: 8)
            )
        }
        .padding(.horizontal, 8)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                appeared = true
            }
        }
    }
}

// MARK: - Step Row

private struct StepRow: View {
    let number: String
    let icon: String
    let text: LocalizedStringKey

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(.blue.opacity(0.1))
                    .frame(width: 30, height: 30)
                Text(number)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.blue)
            }

            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .frame(width: 20)

            Text(text)
                .font(.system(size: 13))
        }
    }
}

// MARK: - Triangle Shape

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}
