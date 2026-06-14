import SwiftUI

struct ToolExecutionCardView: View {
    let card: ToolCard
    @State private var shimmerActive = true

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(card.toolType.cardColor.opacity(0.2))
                    .frame(width: 38, height: 38)
                Image(systemName: card.toolType.iconName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(card.toolType.cardColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(card.toolType.rawValue)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)

                    if card.status == .running {
                        ProgressView()
                            .tint(.white.opacity(0.6))
                            .scaleEffect(0.7)
                    } else {
                        Image(systemName: card.status == .completed ? "checkmark" : "xmark")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(card.status.color)
                    }
                }

                if !card.detail.isEmpty {
                    Text(card.detail)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.55))
                        .lineLimit(1)
                }

                if let result = card.result {
                    Text(result)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                        .lineLimit(2)
                }
            }

            Spacer()

            // Status dot
            Circle()
                .fill(card.status.color)
                .frame(width: 7, height: 7)
                .shadow(color: card.status.color, radius: 3)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .glassCard(cornerRadius: 14, tint: card.toolType.cardColor)
        .shimmer(isActive: card.status == .running)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    VStack(spacing: 8) {
        ToolExecutionCardView(card: ToolCard(toolType: .browser, status: .running, detail: "Loading https://example.com"))
        ToolExecutionCardView(card: ToolCard(toolType: .python, status: .completed, detail: "print('Hello world')", result: "Hello world"))
        ToolExecutionCardView(card: ToolCard(toolType: .generateImage, status: .running, detail: "A futuristic cityscape at night"))
    }
    .padding()
    .background(Color.black)
}
