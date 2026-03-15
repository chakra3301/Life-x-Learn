import Foundation
import TutorCore

/// Detects stale knowledge and suggests refresh activities
public struct RefreshEngine: Sendable {

    /// How many days before knowledge is considered "stale"
    public let staleThresholdDays: Int

    public init(staleThresholdDays: Int = 30) {
        self.staleThresholdDays = staleThresholdDays
    }

    /// Identify knowledge items that need refreshing
    public func findStaleItems(
        items: [(id: UUID, title: String, lastReviewedAt: Date?, importedAt: Date)]
    ) -> [StaleItem] {
        let now = Date()
        let calendar = Calendar.current

        return items.compactMap { item in
            let referenceDate = item.lastReviewedAt ?? item.importedAt
            let daysSince = calendar.dateComponents([.day], from: referenceDate, to: now).day ?? 0

            guard daysSince >= staleThresholdDays else { return nil }

            let staleness: Staleness
            switch daysSince {
            case staleThresholdDays..<(staleThresholdDays * 2):
                staleness = .mild
            case (staleThresholdDays * 2)..<(staleThresholdDays * 4):
                staleness = .moderate
            default:
                staleness = .severe
            }

            return StaleItem(
                id: item.id,
                title: item.title,
                daysSinceReview: daysSince,
                staleness: staleness
            )
        }
        .sorted { $0.daysSinceReview > $1.daysSinceReview }
    }

    /// Suggest a refresh activity for a stale item
    public func suggestActivity(for staleness: Staleness) -> RefreshActivity {
        switch staleness {
        case .mild:
            return .quickReview  // Just re-read the summary
        case .moderate:
            return .flashcardSession  // Review flashcards
        case .severe:
            return .fullRelearn  // Take a quiz, re-study the material
        }
    }
}

// MARK: - Supporting Types

public struct StaleItem: Identifiable, Sendable {
    public let id: UUID
    public let title: String
    public let daysSinceReview: Int
    public let staleness: Staleness
}

public enum Staleness: String, Sendable, Comparable {
    case mild
    case moderate
    case severe

    public static func < (lhs: Staleness, rhs: Staleness) -> Bool {
        let order: [Staleness] = [.mild, .moderate, .severe]
        return (order.firstIndex(of: lhs) ?? 0) < (order.firstIndex(of: rhs) ?? 0)
    }
}

public enum RefreshActivity: String, Sendable {
    case quickReview = "Quick Review"
    case flashcardSession = "Flashcard Session"
    case fullRelearn = "Full Re-Learn"
}
