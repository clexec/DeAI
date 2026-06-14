import SwiftUI

struct HomeView: View {
    @Environment(AppState.self) private var appState
    @State private var scrollOffset: CGFloat = 0
    @State private var showModelSelector = false
    @State private var showChats = false
    @State private var modelPulse = false

    var body: some View {
        ZStack {
            AnimatedBackground(parallaxOffset: scrollOffset)

            VStack(spacing: 0) {
                topBar
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                Spacer()

                modelHero
                    .padding(.horizontal, 24)

                Spacer()
            }

            // Floating composer at bottom
            VStack {
                Spacer()
                ComposerView()
                    .padding(.horizontal, 16)
                    .padding(.bottom, 4)
            }
        }
        .sheet(isPresented: $showModelSelector) {
            ModelSelectorView()
        }
        .sheet(isPresented: $showChats) {
            SidebarView()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                modelPulse = true
            }
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack(spacing: 12) {
            // Chats + Settings glass capsule
            chatSettingsCapsule

            Spacer()

            // New conversation button
            GlassButton(icon: "plus", shape: .circle) {
                let conv = appState.createNewConversation()
                appState.navigationPath.append(.chat(conv.id))
            }
            .foregroundStyle(.white)
        }
    }

    @ViewBuilder
    private var chatSettingsCapsule: some View {
        HStack(spacing: 0) {
            Button {
                showChats = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "bubble.left.and.bubble.right")
                    Text("Chats").font(.subheadline.weight(.medium))
                }
                .padding(.horizontal, 14).padding(.vertical, 9)
            }
            Rectangle().fill(.white.opacity(0.2)).frame(width: 1, height: 18)
            Button {
                appState.navigationPath.append(.settings)
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "gear")
                    Text("Settings").font(.subheadline.weight(.medium))
                }
                .padding(.horizontal, 14).padding(.vertical, 9)
            }
        }
        .foregroundStyle(.white)
        .background(.ultraThinMaterial, in: Capsule())
    }

    // MARK: - Model Hero

    private var modelHero: some View {
        VStack(spacing: 16) {
            // Provider badge
            ProviderBadge(provider: appState.selectedProviderType, size: 52)
                .shadow(color: appState.selectedProviderType.brandColor.opacity(0.5), radius: 16)
                .scaleEffect(modelPulse ? 1.04 : 1.0)

            // Model name — tappable to open selector
            Button {
                showModelSelector = true
            } label: {
                VStack(spacing: 6) {
                    HStack(spacing: 8) {
                        Text(appState.selectedModel.name)
                            .font(.system(size: 38, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        Image(systemName: "chevron.down")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.6))
                    }

                    Text(appState.selectedModel.description)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.65))
                        .multilineTextAlignment(.center)

                    // Capability chips
                    HStack(spacing: 8) {
                        if appState.selectedModel.supportsReasoning {
                            CapabilityChip(label: "Reasoning", icon: "brain")
                        }
                        if appState.selectedModel.supportsVision {
                            CapabilityChip(label: "Vision", icon: "eye")
                        }
                        CapabilityChip(
                            label: "\(appState.selectedModel.contextWindow / 1000)K ctx",
                            icon: "text.word.spacing"
                        )
                    }
                    .padding(.top, 4)
                }
            }

            // Suggestion pills
            suggestionRow
        }
    }

    private var suggestionRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(suggestions, id: \.self) { suggestion in
                    Button {
                        let conv = appState.createNewConversation()
                        appState.navigationPath.append(.chat(conv.id))
                    } label: {
                        Text(suggestion)
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(.white.opacity(0.8))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .glassCapsule()
                    }
                }
            }
            .padding(.horizontal, 24)
        }
        .padding(.top, 8)
    }

    private let suggestions = [
        "Write an email", "Explain a concept", "Debug code",
        "Generate an image", "Research a topic", "Build a website"
    ]
}

private struct CapabilityChip: View {
    let label: String
    let icon: String

    var body: some View {
        Label(label, systemImage: icon)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(.white.opacity(0.7))
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .glassCapsule()
    }
}

#Preview {
    HomeView()
        .environment(AppState())
}
