import Foundation
import TutorCore

/// Service for discovering and managing cross-topic connections
public final class KnowledgeGraphService: @unchecked Sendable {

    public init() {}

    /// Find potential connections between knowledge items based on content similarity
    public func findConnections(
        embeddings: [(id: UUID, embedding: [Float])],
        threshold: Double = 0.7
    ) -> [(itemA: UUID, itemB: UUID, similarity: Double)] {
        var connections: [(UUID, UUID, Double)] = []

        for i in 0..<embeddings.count {
            for j in (i + 1)..<embeddings.count {
                let similarity = cosineSimilarity(embeddings[i].embedding, embeddings[j].embedding)
                if similarity >= threshold {
                    connections.append((embeddings[i].id, embeddings[j].id, similarity))
                }
            }
        }

        return connections.sorted { $0.2 > $1.2 }
    }

    /// Cosine similarity between two vectors
    private func cosineSimilarity(_ a: [Float], _ b: [Float]) -> Double {
        guard a.count == b.count, !a.isEmpty else { return 0 }
        var dotProduct: Float = 0
        var normA: Float = 0
        var normB: Float = 0

        for i in 0..<a.count {
            dotProduct += a[i] * b[i]
            normA += a[i] * a[i]
            normB += b[i] * b[i]
        }

        let denominator = sqrt(normA) * sqrt(normB)
        guard denominator > 0 else { return 0 }
        return Double(dotProduct / denominator)
    }
}
