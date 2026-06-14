import SwiftUI

struct MainView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        @Bindable var state = appState
        NavigationStack(path: $state.navigationPath) {
            HomeView()
                .toolbarVisibility(.hidden, for: .navigationBar)
                .navigationDestination(for: AppPath.self) { path in
                    destinationView(for: path)
                }
        }
    }

    @ViewBuilder
    private func destinationView(for path: AppPath) -> some View {
        switch path {
        case .home:
            HomeView()

        case .chat(let id):
            if let conv = appState.conversation(for: id) {
                ChatView(conversation: conv)
            } else {
                notFoundView("Conversation not found")
            }

        case .projects:
            ProjectsView()

        case .projectDetail(let id):
            if let project = appState.projects.first(where: { $0.id == id }) {
                ProjectDashboardView(project: project)
            } else {
                notFoundView("Project not found")
            }

        case .favorites:
            FavoritesView()

        case .archive:
            ArchiveView()

        case .downloads:
            DownloadsView()

        case .analytics:
            AnalyticsView()

        case .memory:
            MemoryView()

        case .settings:
            SettingsView()

        case .providerSettings(let id):
            if let provider = appState.providers.first(where: { $0.id == id }) {
                ProviderSettingsView(provider: provider)
            } else {
                notFoundView("Provider not found")
            }

        case .browser:
            BrowserView()

        case .sandbox:
            SandboxView()

        case .imageStudio:
            ImageStudioView()

        case .presentationStudio:
            PresentationStudioView()

        case .documentStudio:
            DocumentStudioView()

        case .websiteBuilder:
            WebsiteBuilderView()

        case .appBuilder:
            AppBuilderView()

        case .marketplace:
            MarketplaceView()

        case .promptLibrary:
            PromptLibraryView()
        }
    }

    @ViewBuilder
    private func notFoundView(_ message: String) -> some View {
        ZStack {
            AnimatedBackground()
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.largeTitle)
                    .foregroundStyle(.white.opacity(0.5))
                Text(message)
                    .foregroundStyle(.white.opacity(0.7))
            }
        }
        .ignoresSafeArea()
    }
}
