import SwiftUI

struct MessageBubble: View {
    let message: ChatMessage
    let viewModel: ChatViewModel

    @State private var showReasoning = false

    private var isUser: Bool { message.role == .user }

    var body: some View {
        VStack(alignment: isUser ? .trailing : .leading, spacing: 0) {
            HStack(alignment: .bottom, spacing: 10) {
                if isUser { Spacer(minLength: 60) }

                VStack(alignment: isUser ? .trailing : .leading, spacing: 6) {
                    // Tool execution cards (assistant only)
                    if !message.toolCards.isEmpty {
                        ForEach(message.toolCards) { card in
                            ToolExecutionCardView(card: card)
                        }
                    }

                    // Agent task plan (assistant only)
                    if !message.agentTasks.isEmpty {
                        AgentTaskPanel(tasks: message.agentTasks)
                    }

                    // Message content
                    if !message.content.isEmpty {
                        messageBubble
                    }

                    // Translated section
                    if let translation = message.translation {
                        translationBubble(translation)
                    }

                    // Reasoning section
                    if let reasoning = message.reasoning {
                        ReasoningSection(data: reasoning, isExpanded: $showReasoning)
                    }
                }

                if !isUser { Spacer(minLength: 60) }
            }

            // Action bar (assistant messages)
            if !isUser && !message.content.isEmpty {
                MessageActionBar(message: message, viewModel: viewModel, showReasoning: $showReasoning)
                    .padding(.leading, 12)
                    .padding(.top, 4)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 5)
    }

    // MARK: - Bubble

    private var messageBubble: some View {
        Text(message.content)
            .font(.body)
            .foregroundStyle(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(bubbleBackground)
            .textSelection(.enabled)
    }

    @ViewBuilder
    private var bubbleBackground: some View {
        if isUser {
            // User: solid blue-purple gradient
            RoundedRectangle(cornerRadius: 18)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.1, green: 0.4, blue: 1.0),
                            Color(red: 0.4, green: 0.1, blue: 0.9)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        } else {
            // AI: glass
            if #available(iOS 26, *) {
                RoundedRectangle(cornerRadius: 18)
                    .fill(.clear)
                    .glassEffect(.regular, in: .rect(cornerRadius: 18))
            } else {
                RoundedRectangle(cornerRadius: 18)
                    .fill(.ultraThinMaterial)
            }
        }
    }

    // MARK: - Translation

    private func translationBubble(_ translation: MessageTranslation) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Label("Translated to \(translation.targetLanguage)", systemImage: "globe")
                .font(.caption2.weight(.medium))
                .foregroundStyle(.white.opacity(0.5))

            Text(translation.translatedText)
                .font(.body)
                .foregroundStyle(.white.opacity(0.9))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .glassCard(cornerRadius: 16, tint: .cyan)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Generated image bubble

private struct GeneratedImageBubble: View {
    let url: URL

    var body: some View {
        AsyncImage(url: url) { image in
            image.resizable().scaledToFill()
        } placeholder: {
            Rectangle().fill(.white.opacity(0.1)).shimmer(isActive: true)
        }
        .frame(maxWidth: 260)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
