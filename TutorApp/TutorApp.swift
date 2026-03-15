import SwiftUI
import SwiftData
import TutorData
import TutorUI
import TutorAI
import TutorCore

@main
struct TutorApp: App {
    let modelContainer: ModelContainer
    @State private var themeManager = ThemeManager()

    init() {
        do {
            modelContainer = try TutorSchema.createContainer()
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(themeManager)
                .environment(\.tutorTheme, themeManager.currentTheme)
        }
        .modelContainer(modelContainer)

        #if os(macOS)
        Settings {
            SettingsView()
                .environment(themeManager)
        }
        #endif
    }
}

// Placeholder for settings
struct SettingsView: View {
    var body: some View {
        Text("Settings")
            .frame(width: 400, height: 300)
    }
}
