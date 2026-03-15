import Foundation
import TutorCore

/// Tracks daily activity streaks
public struct StreakTracker: Sendable {

    public init() {}

    /// Calculate streak from a list of active dates (sorted descending)
    public func calculateStreak(activeDates: [Date]) -> (current: Int, longest: Int) {
        guard !activeDates.isEmpty else { return (0, 0) }

        let calendar = Calendar.current
        let sortedDays = activeDates
            .map { calendar.startOfDay(for: $0) }
            .sorted(by: >)

        // Remove duplicates (same day)
        var uniqueDays: [Date] = []
        for day in sortedDays {
            if uniqueDays.last != day {
                uniqueDays.append(day)
            }
        }

        let today = calendar.startOfDay(for: Date())

        // Current streak
        var currentStreak = 0
        var checkDate = today

        // Allow today or yesterday as the start
        if let first = uniqueDays.first, first != today {
            let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
            if first != yesterday {
                // Streak is broken
                currentStreak = 0
            } else {
                checkDate = yesterday
            }
        }

        for day in uniqueDays {
            if day == checkDate {
                currentStreak += 1
                checkDate = calendar.date(byAdding: .day, value: -1, to: checkDate)!
            } else if day < checkDate {
                break
            }
        }

        // Longest streak
        var longestStreak = 0
        var tempStreak = 1
        for i in 1..<uniqueDays.count {
            let expected = calendar.date(byAdding: .day, value: -1, to: uniqueDays[i - 1])!
            if uniqueDays[i] == expected {
                tempStreak += 1
            } else {
                longestStreak = max(longestStreak, tempStreak)
                tempStreak = 1
            }
        }
        longestStreak = max(longestStreak, tempStreak)

        return (current: currentStreak, longest: max(longestStreak, currentStreak))
    }

    /// Check if user is active today
    public func isActiveToday(lastActiveDate: Date?) -> Bool {
        guard let lastActive = lastActiveDate else { return false }
        return Calendar.current.isDateInToday(lastActive)
    }

    /// Check if streak is at risk (last active yesterday, not yet today)
    public func isStreakAtRisk(lastActiveDate: Date?) -> Bool {
        guard let lastActive = lastActiveDate else { return false }
        return Calendar.current.isDateInYesterday(lastActive)
    }
}
