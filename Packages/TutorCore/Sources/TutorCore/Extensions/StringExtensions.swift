import Foundation

public extension String {
    /// Truncates the string to a maximum length, appending a suffix if truncated
    func truncated(to maxLength: Int, suffix: String = "…") -> String {
        guard count > maxLength else { return self }
        let endIndex = index(startIndex, offsetBy: maxLength - suffix.count)
        return String(self[..<endIndex]) + suffix
    }

    /// Estimates the token count (rough approximation: ~4 chars per token)
    var estimatedTokenCount: Int {
        max(1, count / 4)
    }

    /// Returns the string with leading and trailing whitespace/newlines removed
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Splits text into paragraphs
    var paragraphs: [String] {
        components(separatedBy: "\n\n")
            .map { $0.trimmed }
            .filter { !$0.isEmpty }
    }

    /// Splits text into sentences
    var sentences: [String] {
        var result: [String] = []
        let tagger = NSLinguisticTagger(tagSchemes: [.tokenType], options: 0)
        tagger.string = self
        tagger.enumerateTags(
            in: NSRange(location: 0, length: utf16.count),
            unit: .sentence,
            scheme: .tokenType,
            options: []
        ) { _, tokenRange, _ in
            let range = Range(tokenRange, in: self)!
            let sentence = String(self[range]).trimmed
            if !sentence.isEmpty {
                result.append(sentence)
            }
        }
        return result
    }
}
