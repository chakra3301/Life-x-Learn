import Foundation
import SwiftData
import TutorCore

@Model
public final class TutorPersonality {
    public var id: UUID = UUID()
    public var tone: String = TutorTone.friendly.rawValue
    public var verbosity: Int = 3
    public var useEmoji: Bool = false
    public var customInstructions: String = ""

    public var user: UserProfile?

    public init(tone: TutorTone = .friendly, verbosity: Int = 3) {
        self.id = UUID()
        self.tone = tone.rawValue
        self.verbosity = verbosity
    }

    public var tutorTone: TutorTone {
        get { TutorTone(rawValue: tone) ?? .friendly }
        set { tone = newValue.rawValue }
    }
}
