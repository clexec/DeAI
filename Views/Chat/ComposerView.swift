import SwiftUI

struct ComposerView: View {
    @Environment(AppState.self) private var appState
    var viewModel: ChatViewModel?

    @State private var text = ""
    @State private var showPlusMenu = false
    @FocusState private var isFocused: Bool
    @Namespace private var plusMenuAnimation

    var body: some View {
        VStack(spacing: 8) {
            // Plus menu (expands upward)
            if showPlusMenu {
                plusMenuPanel
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .move(edge: .bottom).combined(with: .opacity)
                    ))
            }

            // Composer bar
            composerBar
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.75), value: showPlusMenu)
    }

    // MARK: - Composer Bar

    private var composerBar: some View {
        HStack(alignment: .bottom, spacing: 10) {
            // Plus button
            Button {
                isFocused = false
                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                    showPlusMenu.toggle()
                }
            } label: {
                Image(systemName: showPlusMenu ? "xmark" : "plus")
                    .font(.body.weight(.semibold))
                    .frame(width: 36, height: 36)
                    .foregroundStyle(.white)
                    .glassCircle(interactive: true)
                    .rotationEffect(.degrees(showPlusMenu ? 45 : 0))
            }

            // Text field
            TextField("", text: $text, prompt: Text("Message De AI…").foregroundStyle(.white.opacity(0.4)), axis: .vertical)
                .font(.body)
                .foregroundStyle(.white)
                .lineLimit(1...6)
                .focused($isFocused)
                .textInputAutocapitalization(.sentences)
                .onSubmit { send() }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .glassCard(cornerRadius: 20)

            // Mic or Send
            if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Button {
                    // Voice recording
                } label: {
                    Image(systemName: "waveform")
                        .font(.body.weight(.semibold))
                        .frame(width: 36, height: 36)
                        .foregroundStyle(.white)
                        .glassCircle(interactive: true)
                }
            } else {
                SendButton(action: send)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .glassCard(cornerRadius: 28)
        .shadow(color: .black.opacity(0.25), radius: 20, y: 8)
    }

    // MARK: - Plus Menu

    private var plusMenuPanel: some View {
        LazyVGrid(columns: [.init(.flexible()), .init(.flexible()), .init(.flexible())], spacing: 10) {
            ForEach(PlusMenuItem.all, id: \.label) { item in
                PlusMenuButton(item: item) {
                    withAnimation { showPlusMenu = false }
                    item.action(appState)
                }
            }
        }
        .padding(14)
        .glassCard(cornerRadius: 24)
        .shadow(color: .black.opacity(0.3), radius: 24, y: 8)
    }

    // MARK: - Helpers

    private func send() {
        guard let viewModel else {
            // Home screen: create conversation first
            let conv = appState.createNewConversation()
            appState.navigationPath.append(.chat(conv.id))
            return
        }
        if !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            viewModel.inputText = text
            viewModel.sendMessage(appState: appState)
            text = ""
            isFocused = false
        }
    }
}

private struct SendButton: View {
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: "arrow.up")
                .font(.body.weight(.bold))
                .frame(width: 36, height: 36)
                .foregroundStyle(.white)
                .glassCircle(tint: .blue, interactive: true)
        }
    }
}

// MARK: - Plus Menu Items

struct PlusMenuItem {
    let icon: String
    let label: String
    let color: Color
    let action: (AppState) -> Void

    nonisolated(unsafe) static let all: [PlusMenuItem] = [
        PlusMenuItem(icon: "paperclip", label: "Attach File", color: .blue) { _ in },
        PlusMenuItem(icon: "photo", label: "Photo", color: .purple) { _ in },
        PlusMenuItem(icon: "camera", label: "Camera", color: .orange) { _ in },
        PlusMenuItem(icon: "waveform", label: "Audio", color: .green) { _ in },
        PlusMenuItem(icon: "video", label: "Video", color: .red) { _ in },
        PlusMenuItem(icon: "doc.richtext", label: "PDF", color: .pink) { _ in },
        PlusMenuItem(icon: "globe", label: "Website", color: .cyan) { state in
            state.navigationPath.append(.browser)
        },
        PlusMenuItem(icon: "photo.badge.plus", label: "Gen Image", color: .indigo) { state in
            state.navigationPath.append(.imageStudio)
        },
        PlusMenuItem(icon: "rectangle.stack", label: "Presentation", color: .yellow) { state in
            state.navigationPath.append(.presentationStudio)
        },
        PlusMenuItem(icon: "tablecells", label: "Spreadsheet", color: .teal) { _ in },
        PlusMenuItem(icon: "folder.badge.plus", label: "Project", color: .mint) { state in
            state.navigationPath.append(.projects)
        },
        PlusMenuItem(icon: "bolt.fill", label: "AI Agent", color: .orange) { _ in },
    ]
}

private struct PlusMenuButton: View {
    let item: PlusMenuItem
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 7) {
                ZStack {
                    Circle()
                        .fill(item.color.opacity(0.2))
                        .frame(width: 46, height: 46)
                    Image(systemName: item.icon)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(item.color)
                }
                Text(item.label)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.white.opacity(0.75))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
        .sensoryFeedback(.impact(flexibility: .soft), trigger: false)
    }
}
