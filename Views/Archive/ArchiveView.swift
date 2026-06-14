import SwiftUI

struct ArchiveView: View {
    @Environment(AppState.self) private var appState
    @State private var searchText = ""

    private var filtered: [Conversation] {
        guard !searchText.isEmpty else { return appState.archivedConversations }
        return appState.archivedConversations.filter {
            $0.title.localizedCaseInsensitiveContains(searchText) ||
            $0.preview.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        ZStack {
            AnimatedBackground()

            VStack(spacing: 0) {
                HStack {
                    Text("Archive")
                        .font(.title.weight(.bold))
                        .foregroundStyle(.white)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass").foregroundStyle(.white.opacity(0.5))
                    TextField("", text: $searchText, prompt: Text("Search archive…").foregroundStyle(.white.opacity(0.4)))
                        .foregroundStyle(.white)
                        .autocorrectionDisabled()
                }
                .padding(.horizontal, 14).padding(.vertical, 11)
                .glassCard(cornerRadius: 14)
                .padding(.horizontal, 20)
                .padding(.top, 12)

                ScrollView {
                    LazyVStack(spacing: 10) {
                        if filtered.isEmpty {
                            VStack(spacing: 14) {
                                Image(systemName: "archivebox")
                                    .font(.system(size: 52))
                                    .foregroundStyle(.white.opacity(0.3))
                                Text("Archive is empty")
                                    .font(.title3.weight(.semibold))
                                    .foregroundStyle(.white.opacity(0.6))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 80)
                        } else {
                            ForEach(filtered) { conv in
                                ArchivedConversationRow(conversation: conv)
                            }
                        }
                        Color.clear.frame(height: 30)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                }
            }
        }
        .ignoresSafeArea()
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct ArchivedConversationRow: View {
    @Environment(AppState.self) private var appState
    let conversation: Conversation

    var body: some View {
        HStack(spacing: 12) {
            ProviderBadge(provider: conversation.providerType, size: 38)
                .opacity(0.7)

            VStack(alignment: .leading, spacing: 3) {
                Text(conversation.title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.75))
                Text(conversation.preview)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.4))
                    .lineLimit(1)
                Text(conversation.updatedAt, format: .dateTime.month().day().year())
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.3))
            }
            Spacer()

            Menu {
                Button("Restore", systemImage: "arrow.uturn.backward") {
                    appState.restoreConversation(conversation.id)
                }
                Button("Open Chat", systemImage: "bubble.right") {
                    appState.restoreConversation(conversation.id)
                    appState.navigationPath.append(.chat(conversation.id))
                }
                Divider()
                Button("Delete Permanently", systemImage: "trash", role: .destructive) {
                    appState.deleteConversation(conversation.id)
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.4))
                    .frame(width: 32, height: 32)
                    .glassCircle(interactive: true)
            }
        }
        .padding(14)
        .glassCard(cornerRadius: 16)
    }
}
