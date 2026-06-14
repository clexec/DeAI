import SwiftUI

struct ChatView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: ChatViewModel
    @State private var scrollProxy: ScrollViewProxy?
    @State private var scrollOffset: CGFloat = 0

    init(conversation: Conversation) {
        _viewModel = State(initialValue: ChatViewModel(conversation: conversation))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            AnimatedBackground(parallaxOffset: scrollOffset)

            VStack(spacing: 0) {
                chatNavBar
                messageList
            }

            // Floating composer
            ComposerView(viewModel: viewModel)
                .padding(.horizontal, 16)
                .padding(.bottom, 4)
        }
        .toolbarVisibility(.hidden, for: .navigationBar)
        .ignoresSafeArea(edges: .bottom)
    }

    // MARK: - Nav Bar

    private var chatNavBar: some View {
        HStack(spacing: 12) {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.body.weight(.semibold))
                    .frame(width: 36, height: 36)
                    .foregroundStyle(.white)
                    .glassCircle(interactive: true)
            }

            Spacer()

            VStack(spacing: 1) {
                Text(appState.conversation(for: viewModel.conversationID)?.title ?? "Chat")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Label(appState.selectedModel.name, systemImage: "sparkles")
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.5))
            }

            Spacer()

            Menu {
                Button("Rename", systemImage: "pencil") { }
                Button("Add to favorites", systemImage: "star") { }
                Button("Share", systemImage: "square.and.arrow.up") { }
                Divider()
                Button("Clear conversation", systemImage: "trash", role: .destructive) { }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.body.weight(.semibold))
                    .frame(width: 36, height: 36)
                    .foregroundStyle(.white)
                    .glassCircle(interactive: true)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 8)
    }

    // MARK: - Message List

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 0) {
                    // Spacer for composer overlap
                    Color.clear.frame(height: 8)

                    ForEach(viewModel.messages) { message in
                        MessageBubble(
                            message: message,
                            viewModel: viewModel
                        )
                        .id(message.id)
                    }

                    if viewModel.isLoading && !viewModel.isAgentMode {
                        ThinkingIndicator()
                            .padding(.leading, 20)
                            .padding(.vertical, 8)
                    }

                    // Bottom spacer for composer
                    Color.clear.frame(height: 140)
                        .id("bottom")
                }
                .scrollOffset($scrollOffset)
            }
            .scrollDismissesKeyboard(.interactively)
            .onAppear { scrollProxy = proxy }
            .onChange(of: viewModel.messages.count) {
                withAnimation(.easeOut(duration: 0.3)) {
                    proxy.scrollTo("bottom", anchor: .bottom)
                }
            }
        }
    }
}

// MARK: - Typing indicator

private struct ThinkingIndicator: View {
    @State private var phase = 0

    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .fill(.white.opacity(0.6))
                    .frame(width: 7, height: 7)
                    .offset(y: phase == i ? -5 : 0)
                    .animation(
                        .easeInOut(duration: 0.4).delay(Double(i) * 0.13).repeatForever(),
                        value: phase
                    )
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .glassCard(cornerRadius: 16)
        .onAppear {
            phase = 1
        }
    }
}

// MARK: - Scroll offset tracking

private struct ScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

extension View {
    func scrollOffset(_ offset: Binding<CGFloat>) -> some View {
        self.background(
            GeometryReader { geo in
                Color.clear
                    .preference(key: ScrollOffsetKey.self, value: geo.frame(in: .named("scroll")).minY)
            }
        )
        .coordinateSpace(.named("scroll"))
        .onPreferenceChange(ScrollOffsetKey.self) { offset.wrappedValue = $0 }
    }
}
