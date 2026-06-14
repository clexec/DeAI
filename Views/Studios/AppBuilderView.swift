import SwiftUI

struct AppBuilderView: View {
    @Environment(AppState.self) private var appState
    @State private var appDescription = ""
    @State private var isGenerating = false
    @State private var generatedApp: GeneratedAppData?
    @State private var selectedScreen: AppScreen?
    @FocusState private var descFocused: Bool

    var body: some View {
        ZStack {
            AnimatedBackground()

            VStack(spacing: 0) {
                HStack {
                    Text("App Builder")
                        .font(.title.weight(.bold))
                        .foregroundStyle(.white)
                    Spacer()
                    if generatedApp != nil {
                        Button("Export") { }
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 14).padding(.vertical, 8)
                            .glassCapsule(tint: .indigo)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                if let app = generatedApp {
                    appWorkspace(app: app)
                } else {
                    buildForm
                }
            }
        }
        .ignoresSafeArea()
        .toolbar(.hidden, for: .navigationBar)
        .sheet(item: $selectedScreen) { screen in
            ScreenDetailSheet(screen: screen)
        }
    }

    private var buildForm: some View {
        ScrollView {
            VStack(spacing: 14) {
                GlassCard(cornerRadius: 18) {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("App Concept", systemImage: "apps.iphone")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.5))
                        ZStack(alignment: .topLeading) {
                            if appDescription.isEmpty {
                                Text("e.g. A habit tracking app with streaks, reminders, and social challenges…")
                                    .foregroundStyle(.white.opacity(0.3))
                                    .padding(.top, 2)
                                    .allowsHitTesting(false)
                            }
                            TextEditor(text: $appDescription)
                                .foregroundStyle(.white)
                                .scrollContentBackground(.hidden)
                                .frame(minHeight: 100)
                                .focused($descFocused)
                        }
                    }
                }

                GlassCard(cornerRadius: 18) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Example apps").font(.caption.weight(.semibold)).foregroundStyle(.white.opacity(0.5))
                        let examples = ["Task Manager", "Workout Tracker", "Recipe App", "Journal", "Budgeting", "Social"]
                        LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 2), spacing: 8) {
                            ForEach(examples, id: \.self) { ex in
                                Button(ex) { appDescription = "Build a \(ex.lowercased()) iOS app" }
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(.white.opacity(0.75))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .glassCard(cornerRadius: 10)
                            }
                        }
                    }
                }

                Button {
                    descFocused = false
                    generateApp()
                } label: {
                    HStack(spacing: 10) {
                        if isGenerating {
                            ProgressView().tint(.white)
                            Text("Architecting app…")
                        } else {
                            Image(systemName: "hammer.fill")
                            Text("Generate App Structure")
                        }
                    }
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .glassCard(cornerRadius: 18, tint: .indigo)
                }
                .disabled(appDescription.isEmpty || isGenerating)

                Color.clear.frame(height: 30)
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)
        }
    }

    private func appWorkspace(app: GeneratedAppData) -> some View {
        ScrollView {
            VStack(spacing: 16) {
                // App header
                GlassCard(cornerRadius: 20) {
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 14)
                                .fill(LinearGradient(colors: [.indigo, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 56, height: 56)
                            Image(systemName: "apps.iphone")
                                .font(.title2)
                                .foregroundStyle(.white)
                        }
                        VStack(alignment: .leading, spacing: 3) {
                            Text(app.name)
                                .font(.headline.weight(.bold))
                                .foregroundStyle(.white)
                            Text("\(app.screens.count) screens · \(app.features.count) features")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.5))
                        }
                    }
                }

                // Screens
                VStack(alignment: .leading, spacing: 10) {
                    SectionHeader(title: "Screens", icon: "rectangle.stack")
                    ForEach(app.screens) { screen in
                        Button { selectedScreen = screen } label: {
                            HStack(spacing: 12) {
                                Image(systemName: screen.icon)
                                    .font(.body)
                                    .foregroundStyle(.indigo)
                                    .frame(width: 36, height: 36)
                                    .glassCircle()
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(screen.name)
                                        .font(.subheadline.weight(.medium))
                                        .foregroundStyle(.white)
                                    Text(screen.description)
                                        .font(.caption)
                                        .foregroundStyle(.white.opacity(0.5))
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.3))
                            }
                            .padding(14)
                            .glassCard(cornerRadius: 16)
                        }
                        .buttonStyle(.plain)
                    }
                }

                // Features
                VStack(alignment: .leading, spacing: 10) {
                    SectionHeader(title: "Key Features", icon: "star.fill")
                    ForEach(app.features, id: \.self) { feature in
                        HStack(spacing: 10) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                                .font(.subheadline)
                            Text(feature)
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.85))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .glassCard(cornerRadius: 12)
                    }
                }

                Button("Reset & Rebuild") { withAnimation { generatedApp = nil } }
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.4))
                    .padding(.bottom, 20)
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)
        }
    }

    private func generateApp() {
        isGenerating = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            generatedApp = GeneratedAppData(
                name: String(appDescription.prefix(25)),
                screens: [
                    AppScreen(name: "Onboarding", description: "Welcome flow for new users", icon: "hand.wave"),
                    AppScreen(name: "Home", description: "Main dashboard and overview", icon: "house.fill"),
                    AppScreen(name: "Detail", description: "Detailed view for individual items", icon: "doc.text"),
                    AppScreen(name: "Create", description: "Create new items", icon: "plus.circle"),
                    AppScreen(name: "Profile", description: "User profile and settings", icon: "person.circle"),
                ],
                features: [
                    "User authentication with Face ID",
                    "Real-time data synchronization",
                    "Push notifications",
                    "iCloud backup",
                    "Dark/Light mode support",
                    "Accessibility support (VoiceOver)",
                    "Share extensions",
                    "Home screen widgets",
                ]
            )
            isGenerating = false
        }
    }
}

struct GeneratedAppData {
    let name: String
    let screens: [AppScreen]
    let features: [String]
}

struct AppScreen: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let icon: String
}

private struct ScreenDetailSheet: View {
    @Environment(\.dismiss) private var dismiss
    let screen: AppScreen

    var body: some View {
        ZStack {
            AnimatedBackground()
            VStack(spacing: 20) {
                HStack {
                    Text(screen.name)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)
                    Spacer()
                    Button("Close") { dismiss() }
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding(.horizontal, 20)
                .padding(.top, 28)

                // Screen wireframe
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(red: 0.08, green: 0.08, blue: 0.16))
                    .frame(width: 280, height: 380)
                    .overlay(
                        VStack(spacing: 12) {
                            Image(systemName: screen.icon)
                                .font(.system(size: 40))
                                .foregroundStyle(.indigo.opacity(0.6))
                            Text(screen.name)
                                .font(.headline)
                                .foregroundStyle(.white.opacity(0.6))
                            Text("Wireframe preview")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.3))
                        }
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(.white.opacity(0.1), lineWidth: 1)
                    )

                Text(screen.description)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                Spacer()
            }
        }
        .ignoresSafeArea()
    }
}
