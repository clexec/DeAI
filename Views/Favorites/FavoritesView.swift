import SwiftUI

struct FavoritesView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedFilter: FavoriteItem.FavoriteType?

    private var filtered: [FavoriteItem] {
        guard let filter = selectedFilter else { return appState.favoriteItems }
        return appState.favoriteItems.filter { $0.type == filter }
    }

    var body: some View {
        ZStack {
            AnimatedBackground()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Favorites")
                        .font(.title.weight(.bold))
                        .foregroundStyle(.white)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                // Filter chips
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterChip(label: "All", isSelected: selectedFilter == nil) {
                            selectedFilter = nil
                        }
                        ForEach(FavoriteItem.FavoriteType.allCases, id: \.self) { type in
                            FilterChip(
                                label: type.rawValue.capitalized,
                                icon: type.iconName,
                                isSelected: selectedFilter == type
                            ) {
                                selectedFilter = selectedFilter == type ? nil : type
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.top, 12)

                // Items grid
                ScrollView {
                    if filtered.isEmpty {
                        emptyState
                    } else {
                        LazyVStack(spacing: 10) {
                            ForEach(filtered) { item in
                                FavoriteItemRow(item: item)
                            }
                            Color.clear.frame(height: 30)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                    }
                }
            }
        }
        .ignoresSafeArea()
        .toolbarVisibility(.hidden, for: .navigationBar)
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "star")
                .font(.system(size: 52))
                .foregroundStyle(.white.opacity(0.3))
            Text("No favorites yet")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white.opacity(0.6))
            Text("Star messages, conversations,\nand prompts to save them here")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.4))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }
}

private struct FilterChip: View {
    let label: String
    var icon: String?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Group {
                if let icon {
                    Label(label, systemImage: icon)
                } else {
                    Text(label)
                }
            }
            .font(.subheadline.weight(.medium))
            .foregroundStyle(isSelected ? .white : .white.opacity(0.6))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .glassCapsule(tint: isSelected ? .yellow : nil)
        }
        .sensoryFeedback(.selection, trigger: isSelected)
    }
}

private struct FavoriteItemRow: View {
    let item: FavoriteItem

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.yellow.opacity(0.2))
                    .frame(width: 40, height: 40)
                Image(systemName: item.type.iconName)
                    .font(.body.weight(.medium))
                    .foregroundStyle(.yellow)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(item.title)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white)
                Text(item.content)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
                    .lineLimit(2)
            }
            Spacer()
        }
        .padding(14)
        .glassCard(cornerRadius: 16)
    }
}

extension FavoriteItem.FavoriteType: CaseIterable {
    public static var allCases: [FavoriteItem.FavoriteType] {
        [.conversation, .prompt, .message, .image, .file]
    }
}
