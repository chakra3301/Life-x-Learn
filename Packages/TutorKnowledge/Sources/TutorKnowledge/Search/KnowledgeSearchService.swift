import Foundation
import TutorCore

/// Full-text search across knowledge items
public final class KnowledgeSearchService: KnowledgeSearchable, @unchecked Sendable {

    public init() {}

    public func search(query: String, limit: Int = 20) async throws -> [SearchResult] {
        // This will be backed by SwiftData queries and Core Spotlight
        // Placeholder for the search interface
        return []
    }

    /// Search using embedding similarity (semantic search)
    public func semanticSearch(
        queryEmbedding: [Float],
        candidates: [(id: UUID, title: String, snippet: String, embedding: [Float])],
        limit: Int = 10
    ) -> [SearchResult] {
        let scored = candidates.map { candidate in
            let similarity = cosineSimilarity(queryEmbedding, candidate.embedding)
            return SearchResult(
                id: candidate.id,
                title: candidate.title,
                snippet: candidate.snippet,
                relevanceScore: similarity
            )
        }

        return scored
            .sorted { $0.relevanceScore > $1.relevanceScore }
            .prefix(limit)
            .map { $0 }
    }

    private func cosineSimilarity(_ a: [Float], _ b: [Float]) -> Double {
        guard a.count == b.count, !a.isEmpty else { return 0 }
        var dot: Float = 0, nA: Float = 0, nB: Float = 0
        for i in 0..<a.count {
            dot += a[i] * b[i]; nA += a[i] * a[i]; nB += b[i] * b[i]
        }
        let denom = sqrt(nA) * sqrt(nB)
        return denom > 0 ? Double(dot / denom) : 0
    }
}
