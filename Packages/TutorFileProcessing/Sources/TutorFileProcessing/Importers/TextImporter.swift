import Foundation
import TutorCore

/// Imports plain text, markdown, and rich text documents
public final class TextImporter: FileImporter, @unchecked Sendable {
    public let supportedTypes: [SourceType] = [.note, .document]

    private let textExtensions = ["txt", "md", "rtf", "doc", "docx"]

    public init() {}

    public func canImport(url: URL) -> Bool {
        textExtensions.contains(url.pathExtension.lowercased())
    }

    public func extractText(from url: URL) async throws -> String {
        let ext = url.pathExtension.lowercased()

        switch ext {
        case "txt", "md":
            return try String(contentsOf: url, encoding: .utf8)

        case "rtf", "doc", "docx":
            return try extractFromRichText(url: url)

        default:
            // Try plain text as fallback
            return try String(contentsOf: url, encoding: .utf8)
        }
    }

    public func extractMetadata(from url: URL) async throws -> [String: Any] {
        var metadata: [String: Any] = [:]
        metadata["fileExtension"] = url.pathExtension
        if let attrs = try? FileManager.default.attributesOfItem(atPath: url.path) {
            metadata["fileSize"] = attrs[.size]
        }
        return metadata
    }

    private func extractFromRichText(url: URL) throws -> String {
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.rtf
        ]

        // Try RTF first, then fall back to plain
        if let attributed = try? NSAttributedString(url: url, options: options, documentAttributes: nil) {
            return attributed.string
        }

        #if os(macOS)
        // Try as Word document (macOS only)
        let docOptions: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.docFormat
        ]
        if let attributed = try? NSAttributedString(url: url, options: docOptions, documentAttributes: nil) {
            return attributed.string
        }
        #endif

        // Final fallback: try raw text
        return try String(contentsOf: url, encoding: .utf8)
    }
}
