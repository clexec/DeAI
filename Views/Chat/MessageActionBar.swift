import SwiftUI

struct MessageActionBar: View {
    let message: ChatMessage
    let viewModel: ChatViewModel
    @Binding var showReasoning: Bool
    @State private var copiedFeedback = false

    var body: some View {
        if #available(iOS 26, *) {
            GlassEffectContainer(spacing: 4) {
                HStack(spacing: 4) {
                    actionButton("hand.thumbsup", tint: message.isLiked ? .green : nil) {
                        viewModel.toggleLike(message)
                    }
                    actionButton("hand.thumbsdown", tint: message.isDisliked ? .red : nil) {
                        viewModel.toggleDislike(message)
                    }
                    actionButton(copiedFeedback ? "checkmark" : "doc.on.doc") {
                        viewModel.copyMessage(message)
                        copiedFeedback = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { copiedFeedback = false }
                    }
                    actionButton("globe") { viewModel.translateMessage(message) }
                    actionButton("arrow.clockwise") { viewModel.regenerateLastResponse(appState: AppState()) }
                    actionButton("brain", tint: showReasoning ? .purple : nil) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { showReasoning.toggle() }
                        if !showReasoning { viewModel.expandReasoning(for: message) }
                    }
                    moreMenu
                }
            }
        } else {
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
    }

    // iOS 26+: glass action button
    @available(iOS 26, *)
    @ViewBuilder
    private func actionButton(_ icon: String, tint: Color? = nil, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(tint ?? .white.opacity(0.7))
                .frame(width: 30, height: 30)
        }
        .glassEffect(
            tint != nil
                ? Glass.regular.tint(tint!.opacity(0.35)).interactive()
                : Glass.regular.interactive(),
            in: .circle
        )
        .sensoryFeedback(.impact(flexibility: .soft), trigger: tint != nil)
    }

    // iOS <26 fallback
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
