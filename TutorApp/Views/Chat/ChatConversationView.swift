import SwiftUI
import SwiftData
import TutorCore
import TutorData
import TutorUI
import TutorAI

struct ChatConversationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.tutorTheme) private var theme

    @Query(sort: \Conversation.lastMessageAt, order: .reverse) private var conversations: [Conversation]

    @State private var selectedConversation: Conversation?
    @State private var messageText = ""
    @State private var isLoading = false
    @State private var scrollToBottom = false

    private let localAI = LocalAIService()

    var body: some View {
        NavigationStack {
            if let conversation = selectedConversation {
                chatView(conversation)
            } else {
                conversationListOrNew
            }
        }
    }

    // MARK: - Conversation List

    private var conversationListOrNew: some View {
        Group {
            if conversations.isEmpty {
                newChatWelcome
            } else {
                conversationList
            }
        }
        .navigationTitle("Chat")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    startNewConversation()
                } label: {
                    Image(systemName: "square.and.pencil")
                }
            }
        }
    }

    private var newChatWelcome: some View {
        VStack(spacing: TutorSpacing.lg) {
            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .foregroundStyle(theme.accentColor)

            Text("Chat with your AI tutor")
                .font(TutorTypography.title2)
                .foregroundStyle(theme.textPrimary)

            Text("Ask questions about anything you've uploaded, get explanations, or explore topics together")
                .font(TutorTypography.body)
                .foregroundStyle(theme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, TutorSpacing.xl)

            // Suggestion chips
            VStack(spacing: TutorSpacing.sm) {
                SuggestionChip(text: "Summarize my recent uploads") {
                    startNewConversation(with: "Can you summarize what I've uploaded recently?")
                }
                SuggestionChip(text: "Quiz me on a topic") {
                    startNewConversation(with: "Can you quiz me on something I've been studying?")
                }
                SuggestionChip(text: "Explain a concept") {
                    startNewConversation(with: "I need help understanding a concept. Can you help?")
                }
                SuggestionChip(text: "What should I study next?") {
                    startNewConversation(with: "Based on what I've been learning, what should I study next?")
                }
            }
        }
        .padding()
    }

    private var conversationList: some View {
        List {
            ForEach(conversations) { conversation in
                Button {
                    selectedConversation = conversation
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(conversation.title)
                                .font(TutorTypography.bodyMedium)
                                .foregroundStyle(theme.textPrimary)
                                .lineLimit(1)

                            if let lastMessage = conversation.sortedMessages.last {
                                Text(lastMessage.content)
                                    .font(TutorTypography.caption)
                                    .foregroundStyle(theme.textSecondary)
                                    .lineLimit(2)
                            }
                        }

                        Spacer()

                        if let date = conversation.lastMessageAt {
                            Text(date.relativeDescription)
                                .font(TutorTypography.caption2)
                                .foregroundStyle(theme.textSecondary)
                        }
                    }
                }
            }
            .onDelete { indexSet in
                for index in indexSet {
                    modelContext.delete(conversations[index])
                }
                try? modelContext.save()
            }
        }
    }

    // MARK: - Chat View

    private func chatView(_ conversation: Conversation) -> some View {
        VStack(spacing: 0) {
            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: TutorSpacing.sm) {
                        ForEach(conversation.sortedMessages) { message in
                            ChatBubble(message: message)
                                .id(message.id)
                        }

                        if isLoading {
                            HStack {
                                TypingIndicator()
                                Spacer()
                            }
                            .padding(.horizontal)
                            .id("loading")
                        }
                    }
                    .padding()
                }
                .onChange(of: conversation.messages?.count) {
                    withAnimation {
                        if let lastMessage = conversation.sortedMessages.last {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
                .onChange(of: isLoading) {
                    if isLoading {
                        withAnimation {
                            proxy.scrollTo("loading", anchor: .bottom)
                        }
                    }
                }
            }

            Divider()

            // Input bar
            messageInputBar
        }
        .background(theme.background)
        .navigationTitle(conversation.title)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    selectedConversation = nil
                } label: {
                    Image(systemName: "list.bullet")
                }
            }
        }
    }

    private var messageInputBar: some View {
        HStack(spacing: TutorSpacing.sm) {
            TextField("Ask your tutor anything...", text: $messageText, axis: .vertical)
                .textFieldStyle(.plain)
                .lineLimit(1...5)
                .padding(.horizontal, TutorSpacing.sm)
                .padding(.vertical, TutorSpacing.xs)
                .background(theme.surfaceSecondary)
                .clipShape(RoundedRectangle(cornerRadius: TutorRadius.lg))

            Button {
                Task { await sendMessage() }
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.title2)
                    .foregroundStyle(
                        messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        ? theme.textSecondary
                        : theme.accentColor
                    )
            }
            .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
        }
        .padding()
        .background(theme.surfacePrimary)
    }

    // MARK: - Actions

    private func startNewConversation(with message: String? = nil) {
        let conversation = Conversation(title: "New Chat")
        modelContext.insert(conversation)
        try? modelContext.save()
        selectedConversation = conversation

        if let message {
            messageText = message
            Task { await sendMessage() }
        }
    }

    private func sendMessage() async {
        guard let conversation = selectedConversation else { return }
        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        messageText = ""

        // Add user message
        let userMessage = ChatMessage(role: .user, content: text)
        userMessage.conversation = conversation
        modelContext.insert(userMessage)
        conversation.lastMessageAt = Date()

        // Update title from first message
        if conversation.sortedMessages.count <= 1 {
            conversation.title = String(text.prefix(50))
        }

        try? modelContext.save()

        // Get AI response
        isLoading = true
        defer { isLoading = false }

        do {
            let messages = conversation.sortedMessages.map { msg in
                (role: msg.messageRole, content: msg.content)
            }
            let response = try await localAI.chat(messages: messages, context: nil)

            let assistantMessage = ChatMessage(role: .assistant, content: response)
            assistantMessage.conversation = conversation
            modelContext.insert(assistantMessage)
            conversation.lastMessageAt = Date()
            try? modelContext.save()
        } catch {
            let errorMessage = ChatMessage(role: .assistant, content: "Sorry, I encountered an error: \(error.localizedDescription)")
            errorMessage.conversation = conversation
            modelContext.insert(errorMessage)
            try? modelContext.save()
        }
    }
}

// MARK: - Chat Bubble

struct ChatBubble: View {
    @Environment(\.tutorTheme) private var theme
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.messageRole == .user { Spacer(minLength: 60) }

            VStack(alignment: message.messageRole == .user ? .trailing : .leading, spacing: 2) {
                Text(message.content)
                    .font(TutorTypography.body)
                    .foregroundStyle(message.messageRole == .user ? .white : theme.textPrimary)
                    .padding(.horizontal, TutorSpacing.sm)
                    .padding(.vertical, TutorSpacing.xs)
                    .background(
                        message.messageRole == .user
                        ? theme.accentColor
                        : theme.surfaceSecondary
                    )
                    .clipShape(RoundedRectangle(cornerRadius: TutorRadius.lg))

                Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                    .font(TutorTypography.caption2)
                    .foregroundStyle(theme.textSecondary)
            }

            if message.messageRole == .assistant { Spacer(minLength: 60) }
        }
    }
}

// MARK: - Typing Indicator

struct TypingIndicator: View {
    @State private var animating = false

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                Circle()
                    .fill(Color.gray)
                    .frame(width: 8, height: 8)
                    .scaleEffect(animating ? 1.0 : 0.5)
                    .animation(
                        .easeInOut(duration: 0.6)
                        .repeatForever()
                        .delay(Double(index) * 0.2),
                        value: animating
                    )
            }
        }
        .padding(.horizontal, TutorSpacing.sm)
        .padding(.vertical, TutorSpacing.xs)
        .background(Color.gray.opacity(0.15))
        .clipShape(Capsule())
        .onAppear { animating = true }
    }
}

// MARK: - Suggestion Chip

struct SuggestionChip: View {
    @Environment(\.tutorTheme) private var theme
    let text: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(text)
                .font(TutorTypography.callout)
                .foregroundStyle(theme.accentColor)
                .padding(.horizontal, TutorSpacing.md)
                .padding(.vertical, TutorSpacing.xs)
                .background(theme.accentColor.opacity(0.1))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
