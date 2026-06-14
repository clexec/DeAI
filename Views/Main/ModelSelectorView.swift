import SwiftUI

struct ModelSelectorView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var configuringProvider: AIProvider?
    @Namespace private var animation

    var filteredProviders: [AIProvider] {
        appState.providers.filter { provider in
            provider.isEnabled &&
            (searchText.isEmpty || provider.displayName.localizedCaseInsensitiveContains(searchText)
             || provider.models.contains { $0.name.localizedCaseInsensitiveContains(searchText) })
        }
    }

    var body: some View {
        ZStack {
            AnimatedBackground()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Choose Model")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)
                    Spacer()
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.body.weight(.semibold))
                            .frame(width: 32, height: 32)
                            .foregroundStyle(.white.opacity(0.8))
                            .glassCircle(interactive: true)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)

                // Search
                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.white.opacity(0.5))
                    TextField("", text: $searchText, prompt: Text("Search models…").foregroundStyle(.white.opacity(0.4)))
                        .foregroundStyle(.white)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .glassCard(cornerRadius: 14)
                .padding(.horizontal, 20)
                .padding(.top, 16)

                // Provider list
                ScrollView {
                    LazyVStack(spacing: 16, pinnedViews: []) {
                        ForEach(filteredProviders) { provider in
                            ProviderModelSection(
                                provider: provider,
                                selectedModelID: appState.selectedModelID,
                                animation: animation,
                                onSelect: { model in
                                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                        appState.selectedModelID = model.id
                                        appState.selectedProviderType = model.providerType
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { dismiss() }
                                },
                                onConfigure: { configuringProvider = provider }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
            }
        }
        .ignoresSafeArea()
        .sheet(item: $configuringProvider) { provider in
            ProviderSettingsView(provider: provider)
        }
    }
}

private struct ProviderModelSection: View {
    let provider: AIProvider
    let selectedModelID: String
    let animation: Namespace.ID
    let onSelect: (AIModel) -> Void
    let onConfigure: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Provider header
            HStack(spacing: 10) {
                ProviderBadge(provider: provider.type, size: 36)

                VStack(alignment: .leading, spacing: 1) {
                    Text(provider.displayName)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                    Text(provider.apiKey.isEmpty ? "No API key" : "Configured")
                        .font(.caption)
                        .foregroundStyle(provider.apiKey.isEmpty ? .red.opacity(0.8) : .green.opacity(0.8))
                }
                Spacer()
                Button {
                    onConfigure()
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.6))
                        .padding(8)
                        .glassCircle(interactive: true)
                }
            }

            // Model cards
            ForEach(provider.models) { model in
                ModelCard(
                    model: model,
                    isSelected: model.id == selectedModelID,
                    animation: animation,
                    onSelect: { onSelect(model) }
                )
            }
        }
        .padding(16)
        .glassCard(cornerRadius: 20)
    }
}

private struct ModelCard: View {
    let model: AIModel
    let isSelected: Bool
    let animation: Namespace.ID
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                // Selection indicator
                ZStack {
                    Circle()
                        .strokeBorder(.white.opacity(0.3), lineWidth: 1.5)
                        .frame(width: 22, height: 22)
                    if isSelected {
                        Circle()
                            .fill(model.providerType.brandColor)
                            .frame(width: 14, height: 14)
                            .matchedGeometryEffect(id: "selection", in: animation)
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(model.name)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white)
                    Text(model.description)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.55))
                }
                Spacer()

                // Capability indicators
                HStack(spacing: 6) {
                    if model.supportsReasoning {
                        Image(systemName: "brain")
                            .font(.caption)
                            .foregroundStyle(.purple.opacity(0.8))
                    }
                    if model.supportsVision {
                        Image(systemName: "eye")
                            .font(.caption)
                            .foregroundStyle(.blue.opacity(0.8))
                    }
                }

                StatusDot(status: model.connectionStatus)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                isSelected
                ? model.providerType.brandColor.opacity(0.15)
                : Color.white.opacity(0.05),
                in: RoundedRectangle(cornerRadius: 12)
            )
        }
        .sensoryFeedback(.selection, trigger: isSelected)
    }
}

#Preview {
    ModelSelectorView()
        .environment(AppState())
}
