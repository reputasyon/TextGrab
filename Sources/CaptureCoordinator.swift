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
        overlay?.mode = mode
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
                // Write CGImage directly as PNG - no intermediate conversion
                let bitmap = NSBitmapImageRep(cgImage: image)
                bitmap.size = NSSize(width: image.width, height: image.height)

                NSPasteboard.general.clearContents()

                if let pngData = bitmap.representation(using: .png, properties: [.compressionFactor: 1.0]) {
                    // PNG for full quality
                    NSPasteboard.general.setData(pngData, forType: .png)
                }

                if let tiffData = bitmap.tiffRepresentation {
                    // TIFF for apps that prefer it (Preview, Pages, etc.)
                    NSPasteboard.general.addTypes([.tiff], owner: nil)
                    NSPasteboard.general.setData(tiffData, forType: .tiff)
                }

                let w = image.width
                let h = image.height
                ToastWindow.show("\(L.screenshotCopied) (\(w)x\(h))")
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

        // Find the matching NSScreen for correct scale factor
        let scaleFactor: CGFloat = NSScreen.screens
            .first(where: { screen in
                let cgFrame = convertToDisplayCoords(screen.frame)
                return cgFrame.intersects(cgGlobalRect)
            })?
            .backingScaleFactor ?? 2.0

        let filter = SCContentFilter(display: display, excludingWindows: [])

        let config = SCStreamConfiguration()
        config.sourceRect = localRect
        config.width = Int(localRect.width * scaleFactor)
        config.height = Int(localRect.height * scaleFactor)
        config.showsCursor = false
        config.captureResolution = .best
        config.pixelFormat = kCVPixelFormatType_32BGRA

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
