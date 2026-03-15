// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Tutor",
    platforms: [
        .iOS(.v18),
        .macOS(.v15)
    ],
    products: [
        .library(name: "TutorCore", targets: ["TutorCore"]),
        .library(name: "TutorData", targets: ["TutorData"]),
        .library(name: "TutorAI", targets: ["TutorAI"]),
        .library(name: "TutorFileProcessing", targets: ["TutorFileProcessing"]),
        .library(name: "TutorKnowledge", targets: ["TutorKnowledge"]),
        .library(name: "TutorLearning", targets: ["TutorLearning"]),
        .library(name: "TutorGamification", targets: ["TutorGamification"]),
        .library(name: "TutorStudent", targets: ["TutorStudent"]),
        .library(name: "TutorLife", targets: ["TutorLife"]),
        .library(name: "TutorJournal", targets: ["TutorJournal"]),
        .library(name: "TutorWorkspaces", targets: ["TutorWorkspaces"]),
        .library(name: "TutorIntegrations", targets: ["TutorIntegrations"]),
        .library(name: "TutorChat", targets: ["TutorChat"]),
        .library(name: "TutorUI", targets: ["TutorUI"]),
    ],
    targets: [
        // MARK: - Core
        .target(
            name: "TutorCore",
            path: "Packages/TutorCore/Sources/TutorCore"
        ),
        .testTarget(
            name: "TutorCoreTests",
            dependencies: ["TutorCore"],
            path: "Packages/TutorCore/Tests/TutorCoreTests"
        ),

        // MARK: - Data
        .target(
            name: "TutorData",
            dependencies: ["TutorCore"],
            path: "Packages/TutorData/Sources/TutorData"
        ),
        .testTarget(
            name: "TutorDataTests",
            dependencies: ["TutorData"],
            path: "Packages/TutorData/Tests/TutorDataTests"
        ),

        // MARK: - AI
        .target(
            name: "TutorAI",
            dependencies: ["TutorCore", "TutorData"],
            path: "Packages/TutorAI/Sources/TutorAI"
        ),
        .testTarget(
            name: "TutorAITests",
            dependencies: ["TutorAI"],
            path: "Packages/TutorAI/Tests/TutorAITests"
        ),

        // MARK: - File Processing
        .target(
            name: "TutorFileProcessing",
            dependencies: ["TutorCore", "TutorData"],
            path: "Packages/TutorFileProcessing/Sources/TutorFileProcessing"
        ),
        .testTarget(
            name: "TutorFileProcessingTests",
            dependencies: ["TutorFileProcessing"],
            path: "Packages/TutorFileProcessing/Tests/TutorFileProcessingTests"
        ),

        // MARK: - Knowledge
        .target(
            name: "TutorKnowledge",
            dependencies: ["TutorCore", "TutorData", "TutorAI"],
            path: "Packages/TutorKnowledge/Sources/TutorKnowledge"
        ),
        .testTarget(
            name: "TutorKnowledgeTests",
            dependencies: ["TutorKnowledge"],
            path: "Packages/TutorKnowledge/Tests/TutorKnowledgeTests"
        ),

        // MARK: - Learning
        .target(
            name: "TutorLearning",
            dependencies: ["TutorCore", "TutorData", "TutorAI"],
            path: "Packages/TutorLearning/Sources/TutorLearning"
        ),
        .testTarget(
            name: "TutorLearningTests",
            dependencies: ["TutorLearning"],
            path: "Packages/TutorLearning/Tests/TutorLearningTests"
        ),

        // MARK: - Gamification
        .target(
            name: "TutorGamification",
            dependencies: ["TutorCore", "TutorData"],
            path: "Packages/TutorGamification/Sources/TutorGamification"
        ),
        .testTarget(
            name: "TutorGamificationTests",
            dependencies: ["TutorGamification"],
            path: "Packages/TutorGamification/Tests/TutorGamificationTests"
        ),

        // MARK: - Student
        .target(
            name: "TutorStudent",
            dependencies: ["TutorCore", "TutorData", "TutorAI"],
            path: "Packages/TutorStudent/Sources/TutorStudent"
        ),
        .testTarget(
            name: "TutorStudentTests",
            dependencies: ["TutorStudent"],
            path: "Packages/TutorStudent/Tests/TutorStudentTests"
        ),

        // MARK: - Life
        .target(
            name: "TutorLife",
            dependencies: ["TutorCore", "TutorData", "TutorAI"],
            path: "Packages/TutorLife/Sources/TutorLife"
        ),
        .testTarget(
            name: "TutorLifeTests",
            dependencies: ["TutorLife"],
            path: "Packages/TutorLife/Tests/TutorLifeTests"
        ),

        // MARK: - Journal
        .target(
            name: "TutorJournal",
            dependencies: ["TutorCore", "TutorData", "TutorAI"],
            path: "Packages/TutorJournal/Sources/TutorJournal"
        ),
        .testTarget(
            name: "TutorJournalTests",
            dependencies: ["TutorJournal"],
            path: "Packages/TutorJournal/Tests/TutorJournalTests"
        ),

        // MARK: - Workspaces
        .target(
            name: "TutorWorkspaces",
            dependencies: ["TutorCore", "TutorData"],
            path: "Packages/TutorWorkspaces/Sources/TutorWorkspaces"
        ),
        .testTarget(
            name: "TutorWorkspacesTests",
            dependencies: ["TutorWorkspaces"],
            path: "Packages/TutorWorkspaces/Tests/TutorWorkspacesTests"
        ),

        // MARK: - Integrations
        .target(
            name: "TutorIntegrations",
            dependencies: ["TutorCore", "TutorData"],
            path: "Packages/TutorIntegrations/Sources/TutorIntegrations"
        ),
        .testTarget(
            name: "TutorIntegrationsTests",
            dependencies: ["TutorIntegrations"],
            path: "Packages/TutorIntegrations/Tests/TutorIntegrationsTests"
        ),

        // MARK: - Chat
        .target(
            name: "TutorChat",
            dependencies: ["TutorCore", "TutorData", "TutorAI", "TutorUI"],
            path: "Packages/TutorChat/Sources/TutorChat"
        ),
        .testTarget(
            name: "TutorChatTests",
            dependencies: ["TutorChat"],
            path: "Packages/TutorChat/Tests/TutorChatTests"
        ),

        // MARK: - UI
        .target(
            name: "TutorUI",
            dependencies: ["TutorCore"],
            path: "Packages/TutorUI/Sources/TutorUI"
        ),
        .testTarget(
            name: "TutorUITests",
            dependencies: ["TutorUI"],
            path: "Packages/TutorUI/Tests/TutorUITests"
        ),
    ]
)
