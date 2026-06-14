import SwiftUI

struct DownloadsView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedFilter: DownloadedContent.ContentType?
    @State private var searchText = ""

    private var filtered: [DownloadedContent] {
        appState.downloads.filter { item in
            (selectedFilter == nil || item.type == selectedFilter) &&
            (searchText.isEmpty || item.title.localizedCaseInsensitiveContains(searchText))
        }
    }

    var body: some View {
        ZStack {
            AnimatedBackground()

            VStack(spacing: 0) {
                HStack {
                    Text("Downloads")
                        .font(.title.weight(.bold))
                        .foregroundStyle(.white)
                    Spacer()
                    if !appState.downloads.isEmpty {
                        Menu {
                            Button("Sort by date", systemImage: "calendar") { }
                            Button("Sort by type", systemImage: "tag") { }
                            Button("Sort by size", systemImage: "externaldrive") { }
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease")
                                .font(.body.weight(.medium))
                                .foregroundStyle(.white.opacity(0.7))
                                .frame(width: 36, height: 36)
                                .glassCircle(interactive: true)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                // Filter tabs
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterPill(label: "All", isSelected: selectedFilter == nil) { selectedFilter = nil }
                        ForEach(DownloadedContent.ContentType.allCases, id: \.self) { type in
                            FilterPill(
                                icon: type.iconName,
                                label: type.rawValue.capitalized,
                                isSelected: selectedFilter == type
                            ) { selectedFilter = selectedFilter == type ? nil : type }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.top, 12)

                if filtered.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        LazyVGrid(
                            columns: [.init(.flexible(), spacing: 12), .init(.flexible(), spacing: 12)],
                            spacing: 12
                        ) {
                            ForEach(filtered) { item in
                                DownloadCard(item: item)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                        Color.clear.frame(height: 30)
                    }
                }
            }
        }
        .ignoresSafeArea()
        .toolbar(.hidden, for: .navigationBar)
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "tray")
                .font(.system(size: 52))
                .foregroundStyle(.white.opacity(0.3))
            Text("No downloads yet")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white.opacity(0.6))
            Text("Generated images, documents,\nand files will appear here")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.4))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }
}

private struct FilterPill: View {
    var icon: String?
    let label: String
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
            .font(.caption.weight(.semibold))
            .foregroundStyle(isSelected ? .white : .white.opacity(0.55))
            .padding(.horizontal, 12).padding(.vertical, 7)
            .glassCapsule(tint: isSelected ? .green : nil)
        }
    }
}

private struct DownloadCard: View {
    let item: DownloadedContent

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Thumbnail / Icon
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.white.opacity(0.05))
                    .frame(height: 100)

                if let thumb = item.thumbnailURL {
                    AsyncImage(url: thumb) { img in
                        img.resizable().scaledToFill()
                    } placeholder: {
                        Image(systemName: item.type.iconName)
                            .font(.largeTitle)
                            .foregroundStyle(.white.opacity(0.3))
                    }
                    .frame(height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    Image(systemName: item.type.iconName)
                        .font(.largeTitle)
                        .foregroundStyle(.white.opacity(0.4))
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                HStack {
                    Text(item.type.rawValue.capitalized)
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.4))
                    Spacer()
                    Text(ByteCountFormatter.string(fromByteCount: item.size, countStyle: .file))
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.4))
                }
            }
        }
        .padding(12)
        .glassCard(cornerRadius: 16)
    }
}
