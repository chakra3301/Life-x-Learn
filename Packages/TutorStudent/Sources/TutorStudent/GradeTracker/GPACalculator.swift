import Foundation

/// GPA calculation utilities
public struct GPACalculator: Sendable {

    public init() {}

    /// Standard 4.0 GPA scale
    public func letterGrade(percentage: Double) -> String {
        switch percentage {
        case 93...100: return "A"
        case 90..<93: return "A-"
        case 87..<90: return "B+"
        case 83..<87: return "B"
        case 80..<83: return "B-"
        case 77..<80: return "C+"
        case 73..<77: return "C"
        case 70..<73: return "C-"
        case 67..<70: return "D+"
        case 63..<67: return "D"
        case 60..<63: return "D-"
        default: return "F"
        }
    }

    public func gradePoints(percentage: Double) -> Double {
        switch percentage {
        case 93...100: return 4.0
        case 90..<93: return 3.7
        case 87..<90: return 3.3
        case 83..<87: return 3.0
        case 80..<83: return 2.7
        case 77..<80: return 2.3
        case 73..<77: return 2.0
        case 70..<73: return 1.7
        case 67..<70: return 1.3
        case 63..<67: return 1.0
        case 60..<63: return 0.7
        default: return 0.0
        }
    }

    /// Calculate GPA from a list of (percentage, credit hours)
    public func calculateGPA(courses: [(percentage: Double, credits: Double)]) -> Double {
        guard !courses.isEmpty else { return 0 }
        let totalCredits = courses.reduce(0.0) { $0 + $1.credits }
        guard totalCredits > 0 else { return 0 }

        let weightedPoints = courses.reduce(0.0) { sum, course in
            sum + gradePoints(percentage: course.percentage) * course.credits
        }

        return weightedPoints / totalCredits
    }

    /// Predict final grade given current grades and remaining weight
    public func predictFinalGrade(
        currentPercentage: Double,
        completedWeight: Double,
        targetPercentage: Double
    ) -> Double? {
        guard completedWeight > 0, completedWeight < 1.0 else { return nil }
        let remainingWeight = 1.0 - completedWeight
        let needed = (targetPercentage - currentPercentage * completedWeight) / remainingWeight
        return needed
    }
}
