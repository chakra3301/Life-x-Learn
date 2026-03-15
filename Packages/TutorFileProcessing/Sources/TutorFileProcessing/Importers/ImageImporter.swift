import Foundation
import TutorCore
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// Imports images and extracts text using OCR (Vision framework)
public final class ImageImporter: FileImporter, @unchecked Sendable {
    public let supportedTypes: [SourceType] = [.image, .handwritten]

    private let imageExtensions = ["jpg", "jpeg", "png", "heic", "heif", "tiff", "bmp"]

    public init() {}

    public func canImport(url: URL) -> Bool {
        imageExtensions.contains(url.pathExtension.lowercased())
    }

    public func extractText(from url: URL) async throws -> String {
        guard let cgImage = loadCGImage(from: url) else {
            throw ImportError.extractionFailed("Could not load image")
        }

        let ocrService = OCRService()
        let text = try await ocrService.recognizeText(in: cgImage)

        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ImportError.extractionFailed("No text detected in image")
        }

        return text
    }

    public func extractMetadata(from url: URL) async throws -> [String: Any] {
        var metadata: [String: Any] = [:]
        metadata["fileExtension"] = url.pathExtension
        if let attrs = try? FileManager.default.attributesOfItem(atPath: url.path) {
            metadata["fileSize"] = attrs[.size]
            metadata["creationDate"] = attrs[.creationDate]
        }
        return metadata
    }

    private func loadCGImage(from url: URL) -> CGImage? {
        #if os(macOS)
        guard let nsImage = NSImage(contentsOf: url),
              let cgImage = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return nil
        }
        return cgImage
        #else
        guard let uiImage = UIImage(contentsOfFile: url.path) else {
            return nil
        }
        return uiImage.cgImage
        #endif
    }
}
