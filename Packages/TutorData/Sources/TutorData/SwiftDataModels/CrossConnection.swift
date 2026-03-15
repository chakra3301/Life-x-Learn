import Foundation
import SwiftData

@Model
public final class CrossConnection {
    public var id: UUID = UUID()
    public var connectionDescription: String = ""
    public var strength: Double = 0.0
    public var discoveredAt: Date = Date()

    public var items: [KnowledgeItem]?

    public init(description: String, strength: Double) {
        self.id = UUID()
        self.connectionDescription = description
        self.strength = strength
        self.discoveredAt = Date()
    }
}
