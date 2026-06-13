import Vision
import AppKit

enum OCREngine {
    static func recognizeText(in image: CGImage) async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                let request = VNRecognizeTextRequest { request, error in
                    if let error {
                        continuation.resume(throwing: error)
                        return
                    }

                    let observations = request.results as? [VNRecognizedTextObservation] ?? []

                    // Sort by vertical position (top to bottom), then left to right
                    let sorted = observations.sorted { a, b in
                        let aY = a.boundingBox.origin.y
                        let bY = b.boundingBox.origin.y
                        if abs(aY - bY) > 0.01 {
                            return aY > bY // Higher Y = higher on screen (Vision coords)
                        }
                        return a.boundingBox.origin.x < b.boundingBox.origin.x
                    }

                    let text = sorted
                        .compactMap { $0.topCandidates(1).first?.string }
                        .joined(separator: "\n")

                    continuation.resume(returning: text)
                }

                // Use the newest text-recognition revision the OS supports
                // for better accuracy on small / dense text.
                if VNRecognizeTextRequest.supportedRevisions.contains(VNRecognizeTextRequestRevision3) {
                    request.revision = VNRecognizeTextRequestRevision3
                }
                request.recognitionLevel = .accurate
                request.recognitionLanguages = ["tr", "en", "de", "fr"]
                request.usesLanguageCorrection = true
                // Detect even small text instead of dropping it.
                request.minimumTextHeight = 0.0

                let handler = VNImageRequestHandler(cgImage: image, options: [:])
                do {
                    try handler.perform([request])
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
