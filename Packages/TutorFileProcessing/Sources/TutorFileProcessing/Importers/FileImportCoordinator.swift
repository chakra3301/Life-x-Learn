import Foundation
import TutorCore

/// Central coordinator for importing files of any type
/// Routes files to the appropriate format-specific importer
public actor FileImportCoordinator {
    private let importers: [FileImporter]
    private var processingQueue: [FileProcessingJob] = []
    private var isProcessing = false

    public init(importers: [FileImporter]) {
        self.importers = importers
    }

    /// Convenience initializer with default importers
    public init() {
        self.importers = [
            PDFImporter(),
            ImageImporter(),
            TextImporter(),
            WebImporter(),
        ]
    }

    // MARK: - Import

    /// Import a file and extract its text content
    public func importFile(at url: URL) async throws -> ImportResult {
        guard let importer = importers.first(where: { $0.canImport(url: url) }) else {
            throw ImportError.unsupportedFormat(url.pathExtension)
        }

        let text = try await importer.extractText(from: url)
        let sourceType = detectSourceType(url: url)
        let title = url.deletingPathExtension().lastPathComponent

        return ImportResult(
            title: title,
            rawContent: text,
            sourceType: sourceType,
            sourceURL: url.isFileURL ? nil : url.absoluteString,
            fileSize: fileSize(at: url),
            mimeType: mimeType(for: url)
        )
    }

    /// Queue a file for background processing
    public func enqueue(_ url: URL) async {
        let job = FileProcessingJob(url: url, status: .pending)
        processingQueue.append(job)
        if !isProcessing {
            await processNext()
        }
    }

    // MARK: - Processing Queue

    private func processNext() async {
        guard !processingQueue.isEmpty else {
            isProcessing = false
            return
        }

        isProcessing = true
        var job = processingQueue.removeFirst()
        job.status = .processing

        do {
            let result = try await importFile(at: job.url)
            job.result = result
            job.status = .completed
        } catch {
            job.error = error
            job.status = .failed
        }

        await processNext()
    }

    // MARK: - Helpers

    private func detectSourceType(url: URL) -> SourceType {
        let ext = url.pathExtension.lowercased()
        switch ext {
        case "pdf": return .pdf
        case "jpg", "jpeg", "png", "heic", "heif", "tiff": return .image
        case "mp3", "m4a", "wav", "aac": return .audio
        case "mp4", "mov", "m4v": return .video
        case "doc", "docx", "rtf": return .document
        case "ppt", "pptx", "key": return .slides
        case "txt", "md": return .note
        default:
            if !url.isFileURL { return .webLink }
            return .note
        }
    }

    private func fileSize(at url: URL) -> Int64 {
        guard url.isFileURL else { return 0 }
        let attributes = try? FileManager.default.attributesOfItem(atPath: url.path)
        return attributes?[.size] as? Int64 ?? 0
    }

    private func mimeType(for url: URL) -> String? {
        let ext = url.pathExtension.lowercased()
        let mimeTypes: [String: String] = [
            "pdf": "application/pdf",
            "jpg": "image/jpeg", "jpeg": "image/jpeg",
            "png": "image/png", "heic": "image/heic",
            "mp3": "audio/mpeg", "m4a": "audio/mp4",
            "mp4": "video/mp4", "mov": "video/quicktime",
            "doc": "application/msword",
            "docx": "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
            "txt": "text/plain", "md": "text/markdown",
        ]
        return mimeTypes[ext]
    }
}

// MARK: - Supporting Types

public struct ImportResult: Sendable {
    public let title: String
    public let rawContent: String
    public let sourceType: SourceType
    public let sourceURL: String?
    public let fileSize: Int64
    public let mimeType: String?
}

struct FileProcessingJob {
    let url: URL
    var status: ProcessingStatus
    var result: ImportResult?
    var error: Error?
}

public enum ImportError: Error, LocalizedError {
    case unsupportedFormat(String)
    case extractionFailed(String)
    case fileNotFound

    public var errorDescription: String? {
        switch self {
        case .unsupportedFormat(let ext): return "Unsupported file format: .\(ext)"
        case .extractionFailed(let reason): return "Failed to extract content: \(reason)"
        case .fileNotFound: return "File not found"
        }
    }
}
