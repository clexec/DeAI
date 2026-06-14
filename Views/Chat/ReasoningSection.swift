import SwiftUI

struct ReasoningSection: View {
    let data: ReasoningData
    @Binding var isExpanded: Bool
    @Namespace private var animation

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header toggle
            Button {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.75)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "brain.filled.head.profile")
                        .font(.subheadline)
                        .foregroundStyle(.purple)

                    Text("Reasoning")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)

                    if data.thinkingTokensUsed > 0 {
                        Text("\(data.thinkingTokensUsed) tokens")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.45))
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.5))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
            }
            .glassCard(cornerRadius: 14, tint: .purple)

            // Expanded content
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    if !data.objective.isEmpty {
                        reasoningSection(title: "Objective", icon: "target", content: data.objective, color: .blue)
                    }
                    if !data.assumptions.isEmpty {
                        bulletSection(title: "Assumptions", icon: "list.bullet", items: data.assumptions, color: .cyan)
                    }
                    if !data.analysisSteps.isEmpty {
                        bulletSection(title: "Analysis", icon: "arrow.triangle.branch", items: data.analysisSteps, color: .orange)
                    }
                    if !data.findings.isEmpty {
                        bulletSection(title: "Findings", icon: "magnifyingglass", items: data.findings, color: .yellow)
                    }
                    if !data.conclusion.isEmpty {
                        reasoningSection(title: "Conclusion", icon: "checkmark.seal.fill", content: data.conclusion, color: .green)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .glassCard(cornerRadius: 14, tint: .purple)
                .padding(.top, 4)
                .transition(.asymmetric(
                    insertion: .move(edge: .top).combined(with: .opacity),
                    removal: .move(edge: .top).combined(with: .opacity)
                ))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func reasoningSection(title: String, icon: String, content: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: icon)
                .font(.caption.weight(.semibold))
                .foregroundStyle(color)
            Text(content)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.85))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func bulletSection(title: String, icon: String, items: [String], color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: icon)
                .font(.caption.weight(.semibold))
                .foregroundStyle(color)
            ForEach(items, id: \.self) { item in
                HStack(alignment: .top, spacing: 8) {
                    Circle()
                        .fill(color.opacity(0.6))
                        .frame(width: 5, height: 5)
                        .padding(.top, 6)
                    Text(item)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.85))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}
