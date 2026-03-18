import AppKit

class OverlayWindow: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

class SelectionOverlay {
    private var windows: [NSWindow] = []
    private var completion: ((CGRect?) -> Void)?

    func show(completion: @escaping (CGRect?) -> Void) {
        self.completion = completion

        for screen in NSScreen.screens {
            let window = OverlayWindow(
                contentRect: screen.frame,
                styleMask: .borderless,
                backing: .buffered,
                defer: false
            )
            window.level = .init(Int(CGWindowLevelForKey(.maximumWindow)))
            window.backgroundColor = .clear
            window.isOpaque = false
            window.hasShadow = false
            window.ignoresMouseEvents = false
            window.acceptsMouseMovedEvents = true
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

            let view = SelectionView(frame: NSRect(origin: .zero, size: screen.frame.size))
            view.screenOrigin = screen.frame.origin
            view.onSelection = { [weak self] rect in
                self?.handleSelection(rect)
            }
            view.onCancel = { [weak self] in
                self?.cancel()
            }

            window.contentView = view
            window.makeKeyAndOrderFront(nil)
            window.makeFirstResponder(view)
            windows.append(window)
        }

        NSCursor.crosshair.push()
    }

    private func handleSelection(_ globalRect: CGRect) {
        close()
        completion?(globalRect)
    }

    private func cancel() {
        close()
        completion?(nil)
    }

    private func close() {
        NSCursor.pop()
        windows.forEach { $0.orderOut(nil) }
        windows.removeAll()
    }
}

class SelectionView: NSView {
    var onSelection: ((CGRect) -> Void)?
    var onCancel: (() -> Void)?
    var screenOrigin: CGPoint = .zero

    private var startPoint: NSPoint?
    private var currentRect: NSRect?

    override var acceptsFirstResponder: Bool { true }

    override func mouseDown(with event: NSEvent) {
        startPoint = convert(event.locationInWindow, from: nil)
        currentRect = nil
        needsDisplay = true
    }

    override func mouseDragged(with event: NSEvent) {
        guard let start = startPoint else { return }
        let current = convert(event.locationInWindow, from: nil)

        let rect = NSRect(
            x: min(start.x, current.x),
            y: min(start.y, current.y),
            width: abs(current.x - start.x),
            height: abs(current.y - start.y)
        )
        currentRect = rect
        needsDisplay = true
    }

    override func mouseUp(with event: NSEvent) {
        guard let rect = currentRect, rect.width > 10, rect.height > 10 else {
            onCancel?()
            return
        }

        // Convert view-local rect to global NSScreen coordinates
        let globalRect = CGRect(
            x: screenOrigin.x + rect.origin.x,
            y: screenOrigin.y + rect.origin.y,
            width: rect.width,
            height: rect.height
        )
        onSelection?(globalRect)
    }

    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 { // Escape
            onCancel?()
        }
    }

    override func draw(_ dirtyRect: NSRect) {
        // Semi-transparent dark overlay
        NSColor.black.withAlphaComponent(0.25).setFill()
        bounds.fill()

        guard let rect = currentRect else { return }

        // Clear the selected area
        NSColor.clear.setFill()
        rect.fill(using: .copy)

        // Light tint on selection
        NSColor.systemBlue.withAlphaComponent(0.08).setFill()
        rect.fill()

        // Selection border
        NSColor.systemBlue.setStroke()
        let path = NSBezierPath(rect: rect)
        path.lineWidth = 2
        path.stroke()

        // Size label
        let sizeText = "\(Int(rect.width)) × \(Int(rect.height))"
        let attrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedSystemFont(ofSize: 12, weight: .medium),
            .foregroundColor: NSColor.white,
            .backgroundColor: NSColor.black.withAlphaComponent(0.7)
        ]
        let textSize = (sizeText as NSString).size(withAttributes: attrs)
        let textPoint = NSPoint(
            x: rect.midX - textSize.width / 2,
            y: rect.maxY + 6
        )
        (sizeText as NSString).draw(at: textPoint, withAttributes: attrs)
    }
}
