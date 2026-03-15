import Foundation

/// Splits text into semantic chunks for embedding and retrieval
public struct TextChunker: Sendable {
    /// Target size per chunk in characters (~500 tokens ≈ 2000 chars)
    public let chunkSize: Int
    /// Overlap between adjacent chunks in characters
    public let overlapSize: Int

    public init(chunkSize: Int = 2000, overlapSize: Int = 200) {
        self.chunkSize = chunkSize
        self.overlapSize = overlapSize
    }

    /// Split text into overlapping chunks, respecting paragraph and sentence boundaries
    public func chunk(_ text: String) -> [String] {
        guard !text.isEmpty else { return [] }
        guard text.count > chunkSize else { return [text] }

        let paragraphs = text.components(separatedBy: "\n\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        var chunks: [String] = []
        var currentChunk = ""

        for paragraph in paragraphs {
            if paragraph.count > chunkSize {
                // Paragraph is too large — split by sentences
                if !currentChunk.isEmpty {
                    chunks.append(currentChunk.trimmingCharacters(in: .whitespacesAndNewlines))
                    currentChunk = overlap(from: currentChunk)
                }
                let sentenceChunks = chunkBySentences(paragraph)
                chunks.append(contentsOf: sentenceChunks)
                currentChunk = overlap(from: sentenceChunks.last ?? "")
            } else if (currentChunk + "\n\n" + paragraph).count > chunkSize {
                // Adding this paragraph would exceed chunk size
                chunks.append(currentChunk.trimmingCharacters(in: .whitespacesAndNewlines))
                currentChunk = overlap(from: currentChunk) + paragraph
            } else {
                // Add paragraph to current chunk
                if currentChunk.isEmpty {
                    currentChunk = paragraph
                } else {
                    currentChunk += "\n\n" + paragraph
                }
            }
        }

        if !currentChunk.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            chunks.append(currentChunk.trimmingCharacters(in: .whitespacesAndNewlines))
        }

        return chunks
    }

    // MARK: - Private

    private func chunkBySentences(_ text: String) -> [String] {
        let sentences = splitIntoSentences(text)
        var chunks: [String] = []
        var currentChunk = ""

        for sentence in sentences {
            if (currentChunk + " " + sentence).count > chunkSize && !currentChunk.isEmpty {
                chunks.append(currentChunk.trimmingCharacters(in: .whitespacesAndNewlines))
                currentChunk = overlap(from: currentChunk) + sentence
            } else {
                currentChunk += (currentChunk.isEmpty ? "" : " ") + sentence
            }
        }

        if !currentChunk.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            chunks.append(currentChunk.trimmingCharacters(in: .whitespacesAndNewlines))
        }

        return chunks
    }

    private func splitIntoSentences(_ text: String) -> [String] {
        var sentences: [String] = []
        let tagger = NSLinguisticTagger(tagSchemes: [.tokenType], options: 0)
        tagger.string = text
        tagger.enumerateTags(
            in: NSRange(location: 0, length: text.utf16.count),
            unit: .sentence,
            scheme: .tokenType,
            options: []
        ) { _, tokenRange, _ in
            if let range = Range(tokenRange, in: text) {
                let sentence = String(text[range]).trimmingCharacters(in: .whitespacesAndNewlines)
                if !sentence.isEmpty {
                    sentences.append(sentence)
                }
            }
        }
        // Fallback if no sentences detected
        if sentences.isEmpty {
            return text.components(separatedBy: ". ").filter { !$0.isEmpty }
        }
        return sentences
    }

    private func overlap(from text: String) -> String {
        guard text.count > overlapSize else { return text + " " }
        let startIndex = text.index(text.endIndex, offsetBy: -overlapSize)
        return String(text[startIndex...]) + " "
    }
}
