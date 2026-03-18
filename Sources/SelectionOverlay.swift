import AppKit

class OverlayWindow: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }
}

class SelectionOverlay {
    private var windows: [NSWindow] = []
    private var completion: ((CGRect?) -> Void)?
    var mode: CaptureMode = .ocr

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
            view.mode = mode
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

        // Activate app so first click registers immediately
        NSApp.activate(ignoringOtherApps: true)
        NSCursor.hide()
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
        NSCursor.unhide()
        windows.forEach { $0.orderOut(nil) }
        windows.removeAll()
    }
}

class SelectionView: NSView {
    var onSelection: ((CGRect) -> Void)?
    var onCancel: (() -> Void)?
    var screenOrigin: CGPoint = .zero
    var mode: CaptureMode = .ocr

    private var startPoint: NSPoint?
    private var currentRect: NSRect?
    private var mousePos: NSPoint?
    private var trackingArea: NSTrackingArea?

    override var acceptsFirstResponder: Bool { true }
    override func acceptsFirstMouse(for event: NSEvent?) -> Bool { true }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()
        if let existing = trackingArea {
            removeTrackingArea(existing)
        }
        let area = NSTrackingArea(
            rect: bounds,
            options: [.mouseMoved, .activeAlways, .inVisibleRect],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(area)
        trackingArea = area
    }

    override func mouseMoved(with event: NSEvent) {
        mousePos = convert(event.locationInWindow, from: nil)
        needsDisplay = true
    }

    override func mouseDown(with event: NSEvent) {
        startPoint = convert(event.locationInWindow, from: nil)
        currentRect = nil
        needsDisplay = true
    }

    override func mouseDragged(with event: NSEvent) {
        guard let start = startPoint else { return }
        let current = convert(event.locationInWindow, from: nil)
        mousePos = current

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

        // Draw crosshair + icon at mouse position (before selection starts)
        if let mouse = mousePos, currentRect == nil {
            drawCrosshair(at: mouse)
        }

        // Draw selection
        if let rect = currentRect {
            drawSelection(rect)
        }

        // Draw crosshair during drag too
        if let mouse = mousePos, currentRect != nil {
            drawDragCrosshair(at: mouse)
        }
    }

    // MARK: - Drawing

    private func drawCrosshair(at point: NSPoint) {
        // Full-screen guide lines
        let lineColor = NSColor.white.withAlphaComponent(0.3)
        lineColor.setStroke()

        // Vertical line
        let vLine = NSBezierPath()
        vLine.move(to: NSPoint(x: point.x, y: 0))
        vLine.line(to: NSPoint(x: point.x, y: bounds.height))
        vLine.lineWidth = 0.5
        vLine.setLineDash([4, 4], count: 2, phase: 0)
        vLine.stroke()

        // Horizontal line
        let hLine = NSBezierPath()
        hLine.move(to: NSPoint(x: 0, y: point.y))
        hLine.line(to: NSPoint(x: bounds.width, y: point.y))
        hLine.lineWidth = 0.5
        hLine.setLineDash([4, 4], count: 2, phase: 0)
        hLine.stroke()

        // Center + icon
        let plusSize: CGFloat = 28
        let plusWeight: CGFloat = 2.5

        // Background circle
        let circleRect = NSRect(
            x: point.x - 22,
            y: point.y - 22,
            width: 44,
            height: 44
        )
        NSColor.black.withAlphaComponent(0.5).setFill()
        NSBezierPath(ovalIn: circleRect).fill()
        NSColor.white.withAlphaComponent(0.15).setStroke()
        let circlePath = NSBezierPath(ovalIn: circleRect)
        circlePath.lineWidth = 1
        circlePath.stroke()

        // + sign
        NSColor.white.setStroke()
        let vPlus = NSBezierPath()
        vPlus.move(to: NSPoint(x: point.x, y: point.y - plusSize / 2))
        vPlus.line(to: NSPoint(x: point.x, y: point.y + plusSize / 2))
        vPlus.lineWidth = plusWeight
        vPlus.lineCapStyle = .round
        vPlus.stroke()

        let hPlus = NSBezierPath()
        hPlus.move(to: NSPoint(x: point.x - plusSize / 2, y: point.y))
        hPlus.line(to: NSPoint(x: point.x + plusSize / 2, y: point.y))
        hPlus.lineWidth = plusWeight
        hPlus.lineCapStyle = .round
        hPlus.stroke()

        // Mode label below cursor
        let modeText = mode == .ocr ? "OCR" : "SS"
        let modeAttrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 11, weight: .semibold),
            .foregroundColor: NSColor.white,
        ]
        let modeSize = (modeText as NSString).size(withAttributes: modeAttrs)

        let labelW = modeSize.width + 14
        let labelH = modeSize.height + 6
        let labelRect = NSRect(
            x: point.x - labelW / 2,
            y: point.y - 42,
            width: labelW,
            height: labelH
        )
        let labelBg = NSBezierPath(roundedRect: labelRect, xRadius: 6, yRadius: 6)
        (mode == .ocr
            ? NSColor.systemBlue.withAlphaComponent(0.8)
            : NSColor.systemPurple.withAlphaComponent(0.8)
        ).setFill()
        labelBg.fill()

        (modeText as NSString).draw(
            at: NSPoint(x: labelRect.midX - modeSize.width / 2, y: labelRect.midY - modeSize.height / 2),
            withAttributes: modeAttrs
        )
    }

    private func drawDragCrosshair(at point: NSPoint) {
        // Lighter guide lines during drag
        let lineColor = NSColor.systemBlue.withAlphaComponent(0.25)
        lineColor.setStroke()

        let vLine = NSBezierPath()
        vLine.move(to: NSPoint(x: point.x, y: 0))
        vLine.line(to: NSPoint(x: point.x, y: bounds.height))
        vLine.lineWidth = 0.5
        vLine.setLineDash([4, 4], count: 2, phase: 0)
        vLine.stroke()

        let hLine = NSBezierPath()
        hLine.move(to: NSPoint(x: 0, y: point.y))
        hLine.line(to: NSPoint(x: bounds.width, y: point.y))
        hLine.lineWidth = 0.5
        hLine.setLineDash([4, 4], count: 2, phase: 0)
        hLine.stroke()
    }

    private func drawSelection(_ rect: NSRect) {
        // Clear the selected area
        NSColor.clear.setFill()
        rect.fill(using: .copy)

        // Light tint
        (mode == .ocr
            ? NSColor.systemBlue.withAlphaComponent(0.06)
            : NSColor.systemPurple.withAlphaComponent(0.06)
        ).setFill()
        rect.fill()

        // Border
        let borderColor = mode == .ocr ? NSColor.systemBlue : NSColor.systemPurple
        borderColor.setStroke()
        let path = NSBezierPath(rect: rect)
        path.lineWidth = 2
        path.stroke()

        // Corner handles
        let handleSize: CGFloat = 6
        borderColor.withAlphaComponent(0.8).setFill()
        for point in [
            NSPoint(x: rect.minX, y: rect.minY),
            NSPoint(x: rect.maxX, y: rect.minY),
            NSPoint(x: rect.minX, y: rect.maxY),
            NSPoint(x: rect.maxX, y: rect.maxY),
        ] {
            let handleRect = NSRect(
                x: point.x - handleSize / 2,
                y: point.y - handleSize / 2,
                width: handleSize,
                height: handleSize
            )
            NSBezierPath(roundedRect: handleRect, xRadius: 2, yRadius: 2).fill()
        }

        // Size label
        let sizeText = "\(Int(rect.width)) x \(Int(rect.height))"
        let attrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedSystemFont(ofSize: 12, weight: .medium),
            .foregroundColor: NSColor.white,
        ]
        let textSize = (sizeText as NSString).size(withAttributes: attrs)

        let labelW = textSize.width + 14
        let labelH = textSize.height + 8
        let labelRect = NSRect(
            x: rect.midX - labelW / 2,
            y: rect.maxY + 8,
            width: labelW,
            height: labelH
        )
        let bg = NSBezierPath(roundedRect: labelRect, xRadius: 6, yRadius: 6)
        NSColor.black.withAlphaComponent(0.7).setFill()
        bg.fill()

        (sizeText as NSString).draw(
            at: NSPoint(x: labelRect.midX - textSize.width / 2, y: labelRect.midY - textSize.height / 2),
            withAttributes: attrs
        )
    }
}
