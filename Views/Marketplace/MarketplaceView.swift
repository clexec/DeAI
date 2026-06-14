import SwiftUI

struct MarketplaceView: View {
    @State private var searchText = ""
    @State private var selectedCategory = "All"

    let categories = ["All", "Plugins", "Agents", "Prompts", "Tools", "Themes"]

    var body: some View {
        ZStack {
            AnimatedBackground()

            VStack(spacing: 0) {
                HStack {
                    Text("Marketplace")
                        .font(.title.weight(.bold))
                        .foregroundStyle(.white)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass").foregroundStyle(.white.opacity(0.5))
                    TextField("", text: $searchText, prompt: Text("Search marketplace…").foregroundStyle(.white.opacity(0.4)))
                        .foregroundStyle(.white).autocorrectionDisabled()
                }
                .padding(.horizontal, 14).padding(.vertical, 11)
                .glassCard(cornerRadius: 14)
                .padding(.horizontal, 20).padding(.top, 12)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(categories, id: \.self) { cat in
                            Button(cat) { withAnimation(.smooth) { selectedCategory = cat } }
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(selectedCategory == cat ? .white : .white.opacity(0.55))
                                .padding(.horizontal, 14).padding(.vertical, 8)
                                .glassCapsule(tint: selectedCategory == cat ? .purple : nil)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.top, 10)

                ScrollView {
                    LazyVStack(spacing: 14) {
                        ForEach(sampleItems, id: \.name) { item in
                            MarketplaceItemCard(item: item)
                        }
                        Color.clear.frame(height: 30)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 14)
                }
            }
        }
        .ignoresSafeArea()
        .toolbarVisibility(.hidden, for: .navigationBar)
    }

    private var sampleItems: [MarketplaceItem] {
        [
            MarketplaceItem(name: "Web Research Agent", category: "Agents", description: "Autonomous web research and report generation", rating: 4.8, downloads: 12400, isFree: true),
            MarketplaceItem(name: "Code Review Pro", category: "Tools", description: "AI-powered code review and optimization", rating: 4.6, downloads: 8700, isFree: false),
            MarketplaceItem(name: "Prompt Genius Pack", category: "Prompts", description: "500+ curated prompts for productivity", rating: 4.9, downloads: 34500, isFree: false),
            MarketplaceItem(name: "PDF Analyzer", category: "Plugins", description: "Deep analysis and Q&A for PDF documents", rating: 4.5, downloads: 6200, isFree: true),
            MarketplaceItem(name: "Glass Dark Theme", category: "Themes", description: "Premium dark theme with custom Liquid Glass", rating: 4.7, downloads: 9100, isFree: false),
        ]
    }
}

private struct MarketplaceItem {
    let name: String
    let category: String
    let description: String
    let rating: Double
    let downloads: Int
    let isFree: Bool
}

private struct MarketplaceItemCard: View {
    let item: MarketplaceItem

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.purple.opacity(0.25))
                    .frame(width: 54, height: 54)
                Image(systemName: "puzzlepiece.extension.fill")
                    .font(.title2)
                    .foregroundStyle(.purple)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(item.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                    Spacer()
                    Text(item.isFree ? "Free" : "Pro")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(item.isFree ? .green : .orange)
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background((item.isFree ? Color.green : Color.orange).opacity(0.2), in: Capsule())
                }
                Text(item.description)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.55))
                    .lineLimit(1)
                HStack(spacing: 12) {
                    HStack(spacing: 3) {
                        Image(systemName: "star.fill").font(.caption2).foregroundStyle(.yellow)
                        Text(String(format: "%.1f", item.rating)).font(.caption2).foregroundStyle(.white.opacity(0.5))
                    }
                    HStack(spacing: 3) {
                        Image(systemName: "arrow.down.circle").font(.caption2).foregroundStyle(.white.opacity(0.35))
                        Text("\(item.downloads / 1000)K").font(.caption2).foregroundStyle(.white.opacity(0.5))
                    }
                    Text(item.category)
                        .font(.caption2)
                        .foregroundStyle(.purple.opacity(0.8))
                }
            }
        }
        .padding(14)
        .glassCard(cornerRadius: 18)
    }
}
