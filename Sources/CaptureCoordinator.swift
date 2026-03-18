import AppKit
import ScreenCaptureKit

enum CaptureError: Error {
    case noDisplay
    case captureFailed
}

enum CaptureMode {
    case ocr
    case screenshot
}

@MainActor
class CaptureCoordinator {
    static let shared = CaptureCoordinator()
    private var overlay: SelectionOverlay?

    func startCapture(mode: CaptureMode = .ocr) {
        overlay = SelectionOverlay()
        overlay?.show { [weak self] rect in
            guard let self, let rect else { return }
            Task { @MainActor in
                await self.handleCapture(nsScreenRect: rect, mode: mode)
            }
        }
    }

    private func handleCapture(nsScreenRect: CGRect, mode: CaptureMode) async {
        // Wait for overlay windows to disappear
        try? await Task.sleep(for: .milliseconds(200))

        // Convert NSScreen coords (origin bottom-left) to CG display coords (origin top-left)
        let cgRect = convertToDisplayCoords(nsScreenRect)

        do {
            let image = try await captureRegion(cgRect)

            switch mode {
            case .ocr:
                let text = try await OCREngine.recognizeText(in: image)
                if text.isEmpty {
                    ToastWindow.show(L.noTextFound, isError: true)
                } else {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(text, forType: .string)
                    ToastWindow.show(L.copiedCount(text.count))
                }

            case .screenshot:
                let nsImage = NSImage(cgImage: image, size: NSSize(width: image.width, height: image.height))
                NSPasteboard.general.clearContents()
                NSPasteboard.general.writeObjects([nsImage])
                ToastWindow.show(L.screenshotCopied)
            }
        } catch {
            ToastWindow.show(mode == .ocr ? L.ocrError : L.captureError, isError: true)
        }
    }

    private func captureRegion(_ cgGlobalRect: CGRect) async throws -> CGImage {
        let content = try await SCShareableContent.excludingDesktopWindows(
            false,
            onScreenWindowsOnly: true
        )

        // Find the display containing the selection
        guard let display = content.displays.first(where: { display in
            display.frame.intersects(cgGlobalRect)
        }) else {
            throw CaptureError.noDisplay
        }

        // Convert global CG coords to display-local coords
        let localRect = CGRect(
            x: cgGlobalRect.origin.x - display.frame.origin.x,
            y: cgGlobalRect.origin.y - display.frame.origin.y,
            width: cgGlobalRect.width,
            height: cgGlobalRect.height
        )

        let filter = SCContentFilter(display: display, excludingWindows: [])

        let config = SCStreamConfiguration()
        config.sourceRect = localRect
        let scaleFactor = NSScreen.main?.backingScaleFactor ?? 2.0
        config.width = Int(localRect.width * scaleFactor)
        config.height = Int(localRect.height * scaleFactor)
        config.showsCursor = false
        config.captureResolution = .best

        return try await SCScreenshotManager.captureImage(
            contentFilter: filter,
            configuration: config
        )
    }

    private func convertToDisplayCoords(_ rect: CGRect) -> CGRect {
        guard let primaryScreen = NSScreen.screens.first else { return rect }
        let primaryHeight = primaryScreen.frame.height
        return CGRect(
            x: rect.origin.x,
            y: primaryHeight - rect.origin.y - rect.height,
            width: rect.width,
            height: rect.height
        )
    }
}
