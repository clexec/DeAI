import SwiftUI

struct MessageActionBar: View {
    let message: ChatMessage
    let viewModel: ChatViewModel
    @Binding var showReasoning: Bool
    @State private var copiedFeedback = false

    var body: some View {
        HStack(spacing: 4) {
            legacyActionButton("hand.thumbsup") { viewModel.toggleLike(message) }
            legacyActionButton("hand.thumbsdown") { viewModel.toggleDislike(message) }
            legacyActionButton("doc.on.doc") { viewModel.copyMessage(message) }
            legacyActionButton("globe") { viewModel.translateMessage(message) }
            legacyActionButton("arrow.clockwise") { }
            moreMenu
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(.ultraThinMaterial, in: Capsule())
    }

    @ViewBuilder
    private func legacyActionButton(_ icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white.opacity(0.7))
                .frame(width: 30, height: 30)
        }
    }

    private var moreMenu: some View {
        Menu {
            Button("Share", systemImage: "square.and.arrow.up") { }
            Button("Bookmark", systemImage: "bookmark") { }
            Button("Use as prompt", systemImage: "text.cursor") { }
            Divider()
            Button("Report issue", systemImage: "flag", role: .destructive) { }
        } label: {
            Image(systemName: "ellipsis")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white.opacity(0.7))
                .frame(width: 30, height: 30)
                .background(.white.opacity(0.1), in: Circle())
        }
    }
}
