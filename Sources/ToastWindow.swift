import AppKit

enum ToastWindow {
    private static var currentWindow: NSWindow?

    @MainActor
    static func show(_ message: String, isError: Bool = false) {
        // Close previous toast
        currentWindow?.orderOut(nil)

        let padding: CGFloat = 16
        let attrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 14, weight: .medium),
            .foregroundColor: NSColor.white
        ]
        let textSize = (message as NSString).size(withAttributes: attrs)
        let windowWidth = textSize.width + padding * 2 + 8
        let windowHeight: CGFloat = 40

        guard let screen = NSScreen.main else { return }
        let screenFrame = screen.visibleFrame
        let windowFrame = NSRect(
            x: screenFrame.midX - windowWidth / 2,
            y: screenFrame.minY + 80,
            width: windowWidth,
            height: windowHeight
        )

        let window = NSWindow(
            contentRect: windowFrame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )
        window.level = .floating
        window.backgroundColor = .clear
        window.isOpaque = false
        window.hasShadow = true
        window.ignoresMouseEvents = true

        let bgView = NSVisualEffectView(frame: NSRect(origin: .zero, size: windowFrame.size))
        bgView.material = .hudWindow
        bgView.state = .active
        bgView.wantsLayer = true
        bgView.layer?.cornerRadius = 10
        bgView.layer?.masksToBounds = true

        let label = NSTextField(labelWithString: message)
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = isError ? .systemRed : .white
        label.alignment = .center
        label.sizeToFit()
        label.frame = NSRect(
            x: (windowFrame.width - label.frame.width) / 2,
            y: (windowHeight - label.frame.height) / 2,
            width: label.frame.width,
            height: label.frame.height
        )

        bgView.addSubview(label)
        window.contentView = bgView
        window.alphaValue = 0
        window.makeKeyAndOrderFront(nil)

        currentWindow = window

        // Fade in
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            window.animator().alphaValue = 1
        }

        // Fade out after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.5
                window.animator().alphaValue = 0
            }, completionHandler: {
                window.orderOut(nil)
                if currentWindow === window {
                    currentWindow = nil
                }
            })
        }
    }
}
