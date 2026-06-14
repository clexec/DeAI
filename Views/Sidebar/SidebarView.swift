import SwiftUI

struct SidebarView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""

    private var filteredConversations: [Conversation] {
        guard !searchText.isEmpty else { return appState.activeConversations }
        return appState.activeConversations.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.preview.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        ZStack {
            AnimatedBackground()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Conversations")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)

                    Spacer()

                    Button {
                        dismiss()
                        let conv = appState.createNewConversation()
                        appState.navigationPath.append(.chat(conv.id))
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .font(.body.weight(.semibold))
                            .frame(width: 36, height: 36)
                            .foregroundStyle(.white)
                            .glassCircle(interactive: true)
                    }

                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.body.weight(.semibold))
                            .frame(width: 36, height: 36)
                            .foregroundStyle(.white.opacity(0.7))
                            .glassCircle(interactive: true)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)

                // Quick navigation row
                quickNavRow
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                // Search bar
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.white.opacity(0.5))
                    TextField("", text: $searchText, prompt: Text("Search…").foregroundStyle(.white.opacity(0.4)))
                        .foregroundStyle(.white)
                        .autocorrectionDisabled()
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 11)
                .glassCard(cornerRadius: 14)
                .padding(.horizontal, 20)
                .padding(.top, 12)

                // Conversation list
                ConversationListView(
                    conversations: filteredConversations,
                    onSelect: { conv in
                        dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            appState.navigationPath.append(.chat(conv.id))
                        }
                    }
                )
                .padding(.top, 8)
            }
        }
        .ignoresSafeArea()
    }

    private var quickNavRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                QuickNavButton(icon: "star.fill",         label: "Favorites",  color: .yellow) {
                    dismiss()
                    appState.navigationPath.append(.favorites)
                }
                QuickNavButton(icon: "archivebox.fill",   label: "Archive",    color: .gray) {
                    dismiss()
                    appState.navigationPath.append(.archive)
                }
                QuickNavButton(icon: "folder.fill",       label: "Projects",   color: .blue) {
                    dismiss()
                    appState.navigationPath.append(.projects)
                }
                QuickNavButton(icon: "tray.full.fill",    label: "Downloads",  color: .green) {
                    dismiss()
                    appState.navigationPath.append(.downloads)
                }
                QuickNavButton(icon: "chart.bar.fill",    label: "Analytics",  color: .purple) {
                    dismiss()
                    appState.navigationPath.append(.analytics)
                }
            }
        }
    }
}

private struct QuickNavButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(color)
                    .frame(width: 38, height: 38)
                    .glassCircle(interactive: true)
                Text(label)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.white.opacity(0.65))
            }
        }
    }
}
