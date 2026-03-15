import Foundation
import TutorCore

/// Base protocol for all third-party integrations
public protocol IntegrationService: Sendable {
    var name: String { get }
    var isConnected: Bool { get }

    func connect() async throws
    func disconnect() async throws
    func importItems(limit: Int?) async throws -> [ImportableItem]
}

/// An item that can be imported from a third-party service
public struct ImportableItem: Identifiable, Sendable {
    public let id: String
    public let title: String
    public let content: String
    public let sourceType: SourceType
    public let sourceURL: String?
    public let metadata: [String: String]

    public init(
        id: String,
        title: String,
        content: String,
        sourceType: SourceType = .note,
        sourceURL: String? = nil,
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.sourceType = sourceType
        self.sourceURL = sourceURL
        self.metadata = metadata
    }
}
