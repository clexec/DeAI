import SwiftUI

struct ConversationListView: View {
    @Environment(AppState.self) private var appState
    let conversations: [Conversation]
    let onSelect: (Conversation) -> Void

    @State private var renameTarget: Conversation?
    @State private var renameText = ""

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                // Pinned section
                let pinned = conversations.filter { $0.isPinned }
                if !pinned.isEmpty {
                    SectionHeader(title: "Pinned", icon: "pin.fill")
                        .padding(.horizontal, 20)
                        .padding(.top, 8)

                    ForEach(pinned) { conv in
                        ConversationRow(conversation: conv, onSelect: onSelect, onRename: startRename)
                            .padding(.horizontal, 20)
                    }
                }

                // Recents
                let recents = conversations.filter { !$0.isPinned }
                if !recents.isEmpty {
                    SectionHeader(title: "Recent", icon: "clock")
                        .padding(.horizontal, 20)
                        .padding(.top, 12)

                    ForEach(recents) { conv in
                        ConversationRow(conversation: conv, onSelect: onSelect, onRename: startRename)
                            .padding(.horizontal, 20)
                    }
                }

                if conversations.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "bubble.left.and.bubble.right")
                            .font(.largeTitle)
                            .foregroundStyle(.white.opacity(0.3))
                        Text("No conversations yet")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.4))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 60)
                }

                Color.clear.frame(height: 40)
            }
            .padding(.vertical, 4)
        }
        .alert("Rename", isPresented: .init(
            get: { renameTarget != nil },
            set: { if !$0 { renameTarget = nil } }
        )) {
            TextField("Conversation name", text: $renameText)
            Button("Rename") {
                if let target = renameTarget {
                    appState.renameConversation(target.id, to: renameText)
                }
                renameTarget = nil
            }
            Button("Cancel", role: .cancel) { renameTarget = nil }
        }
    }

    private func startRename(_ conv: Conversation) {
        renameTarget = conv
        renameText = conv.title
    }
}

private struct ConversationRow: View {
    @Environment(AppState.self) private var appState
    let conversation: Conversation
    let onSelect: (Conversation) -> Void
    let onRename: (Conversation) -> Void

    var body: some View {
        Button { onSelect(conversation) } label: {
            HStack(spacing: 12) {
                // Provider badge
                ProviderBadge(provider: conversation.providerType, size: 36)

                VStack(alignment: .leading, spacing: 3) {
                    Text(conversation.title)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white)
                        .lineLimit(1)

                    Text(conversation.preview)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                        .lineLimit(1)
                }
                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(conversation.lastMessageDate, format: .relative(presentation: .named))
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.4))
                    if conversation.isFavorite {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(.yellow.opacity(0.8))
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .glassCard(cornerRadius: 16)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) { appState.deleteConversation(conversation.id) }
                label: { Label("Delete", systemImage: "trash") }
            Button { appState.archiveConversation(conversation.id) }
                label: { Label("Archive", systemImage: "archivebox") }
                .tint(.gray)
        }
        .swipeActions(edge: .leading) {
            Button { appState.togglePin(conversation.id) }
                label: { Label(conversation.isPinned ? "Unpin" : "Pin", systemImage: "pin") }
                .tint(.orange)
            Button { appState.toggleFavorite(conversation.id) }
                label: { Label("Favorite", systemImage: "star") }
                .tint(.yellow)
        }
        .contextMenu {
            Button("Rename", systemImage: "pencil") { onRename(conversation) }
            Button("Pin", systemImage: "pin") { appState.togglePin(conversation.id) }
            Button("Add to favorites", systemImage: "star") { appState.toggleFavorite(conversation.id) }
            Divider()
            Button("Archive", systemImage: "archivebox") { appState.archiveConversation(conversation.id) }
            Button("Delete", systemImage: "trash", role: .destructive) {
                appState.deleteConversation(conversation.id)
            }
        }
    }
}
