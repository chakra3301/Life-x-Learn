import Foundation
import PDFKit
import TutorCore

/// Imports PDF files using PDFKit with OCR fallback for scanned documents
public final class PDFImporter: FileImporter, @unchecked Sendable {
    public let supportedTypes: [SourceType] = [.pdf]

    public init() {}

    public func canImport(url: URL) -> Bool {
        url.pathExtension.lowercased() == "pdf"
    }

    public func extractText(from url: URL) async throws -> String {
        guard let document = PDFDocument(url: url) else {
            throw ImportError.extractionFailed("Could not open PDF")
        }

        var fullText = ""
        for i in 0..<document.pageCount {
            guard let page = document.page(at: i) else { continue }
            if let pageText = page.string, !pageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                fullText += pageText + "\n\n"
            } else {
                // Page has no text — likely scanned, use OCR
                let ocrText = try await ocrPage(page)
                fullText += ocrText + "\n\n"
            }
        }

        let result = fullText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !result.isEmpty else {
            throw ImportError.extractionFailed("No text could be extracted from PDF")
        }
        return result
    }

    public func extractMetadata(from url: URL) async throws -> [String: Any] {
        guard let document = PDFDocument(url: url) else { return [:] }
        var metadata: [String: Any] = [
            "pageCount": document.pageCount
        ]
        if let attrs = document.documentAttributes {
            if let title = attrs[PDFDocumentAttribute.titleAttribute] as? String {
                metadata["title"] = title
            }
            if let author = attrs[PDFDocumentAttribute.authorAttribute] as? String {
                metadata["author"] = author
            }
        }
        return metadata
    }

    // MARK: - OCR Fallback

    private func ocrPage(_ page: PDFPage) async throws -> String {
        #if canImport(Vision)
        let ocrService = OCRService()
        let pageImage = page.thumbnail(of: CGSize(width: 2000, height: 2000), for: .mediaBox)
        #if os(macOS)
        guard let cgImage = pageImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return ""
        }
        #else
        guard let cgImage = pageImage.cgImage else {
            return ""
        }
        #endif
        return try await ocrService.recognizeText(in: cgImage)
        #else
        return ""
        #endif
    }
}
