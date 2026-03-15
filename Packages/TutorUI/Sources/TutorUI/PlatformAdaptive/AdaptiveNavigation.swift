import SwiftUI

/// Platform-adaptive navigation container
/// macOS: NavigationSplitView with sidebar
/// iOS: TabView
public struct AdaptiveRootView<Sidebar: View, Content: View>: View {
    let sidebar: () -> Sidebar
    let content: () -> Content

    public init(
        @ViewBuilder sidebar: @escaping () -> Sidebar,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.sidebar = sidebar
        self.content = content
    }

    public var body: some View {
        #if os(macOS)
        NavigationSplitView {
            sidebar()
        } detail: {
            content()
        }
        #else
        content()
        #endif
    }
}

/// Adaptive list row that adjusts for platform
public struct AdaptiveListRow<Leading: View, Trailing: View>: View {
    let leading: () -> Leading
    let trailing: () -> Trailing

    public init(
        @ViewBuilder leading: @escaping () -> Leading,
        @ViewBuilder trailing: @escaping () -> Trailing
    ) {
        self.leading = leading
        self.trailing = trailing
    }

    public var body: some View {
        HStack {
            leading()
            Spacer()
            trailing()
        }
        #if os(macOS)
        .padding(.vertical, TutorSpacing.xxs)
        #endif
    }
}
