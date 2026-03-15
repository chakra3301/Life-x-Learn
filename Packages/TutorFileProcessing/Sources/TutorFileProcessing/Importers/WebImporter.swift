import Foundation
import TutorCore

/// Imports web content from URLs by fetching and extracting article text
public final class WebImporter: FileImporter, @unchecked Sendable {
    public let supportedTypes: [SourceType] = [.webLink]

    public init() {}

    public func canImport(url: URL) -> Bool {
        !url.isFileURL && (url.scheme == "http" || url.scheme == "https")
    }

    public func extractText(from url: URL) async throws -> String {
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw ImportError.extractionFailed("Failed to fetch URL")
        }

        guard let html = String(data: data, encoding: .utf8) else {
            throw ImportError.extractionFailed("Could not decode response")
        }

        return extractArticleText(from: html)
    }

    public func extractMetadata(from url: URL) async throws -> [String: Any] {
        return [
            "url": url.absoluteString,
            "host": url.host ?? ""
        ]
    }

    /// Basic HTML-to-text extraction
    /// Strips tags, scripts, styles, and navigation elements
    private func extractArticleText(from html: String) -> String {
        var text = html

        // Remove script and style blocks
        text = text.replacingOccurrences(
            of: "<script[^>]*>[\\s\\S]*?</script>",
            with: "",
            options: .regularExpression
        )
        text = text.replacingOccurrences(
            of: "<style[^>]*>[\\s\\S]*?</style>",
            with: "",
            options: .regularExpression
        )

        // Remove nav, header, footer
        for tag in ["nav", "header", "footer", "aside"] {
            text = text.replacingOccurrences(
                of: "<\(tag)[^>]*>[\\s\\S]*?</\(tag)>",
                with: "",
                options: .regularExpression
            )
        }

        // Convert block elements to newlines
        for tag in ["p", "div", "br", "li", "h1", "h2", "h3", "h4", "h5", "h6"] {
            text = text.replacingOccurrences(
                of: "</?\(tag)[^>]*>",
                with: "\n",
                options: .regularExpression
            )
        }

        // Strip remaining HTML tags
        text = text.replacingOccurrences(
            of: "<[^>]+>",
            with: "",
            options: .regularExpression
        )

        // Decode HTML entities
        text = text.replacingOccurrences(of: "&amp;", with: "&")
        text = text.replacingOccurrences(of: "&lt;", with: "<")
        text = text.replacingOccurrences(of: "&gt;", with: ">")
        text = text.replacingOccurrences(of: "&quot;", with: "\"")
        text = text.replacingOccurrences(of: "&#39;", with: "'")
        text = text.replacingOccurrences(of: "&nbsp;", with: " ")

        // Clean up whitespace
        text = text.replacingOccurrences(of: "\\n{3,}", with: "\n\n", options: .regularExpression)
        text = text.trimmingCharacters(in: .whitespacesAndNewlines)

        return text
    }
}
