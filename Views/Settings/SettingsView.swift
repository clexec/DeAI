import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    @State private var showBiometrics = false
    @State private var hapticFeedback = true
    @State private var streamingEnabled = true
    @State private var iCloudSync = false

    var body: some View {
        ZStack {
            AnimatedBackground()

            ScrollView {
                VStack(spacing: 16) {
                    Text("Settings")
                        .font(.title.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 4)

                    // AI Providers
                    SettingsSection(title: "AI Providers", icon: "cpu.fill") {
                        ForEach(appState.providers) { provider in
                            NavigationLink(value: AppPath.providerSettings(provider.id)) {
                                HStack(spacing: 12) {
                                    ProviderBadge(provider: provider.type, size: 36)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(provider.displayName)
                                            .font(.subheadline.weight(.medium))
                                            .foregroundStyle(.white)
                                        Text(provider.isEnabled
                                             ? (provider.apiKey.isEmpty ? "No key" : "Configured")
                                             : "Disabled")
                                            .font(.caption)
                                            .foregroundStyle(
                                                provider.apiKey.isEmpty ? .red.opacity(0.8) : .green.opacity(0.8)
                                            )
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(.white.opacity(0.3))
                                }
                                .padding(.vertical, 4)
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    // Appearance
                    SettingsSection(title: "Appearance", icon: "paintbrush.fill") {
                        SettingsToggle(title: "Haptic feedback", subtitle: "Vibrate on interactions", isOn: $hapticFeedback)
                        SettingsToggle(title: "Streaming", subtitle: "Show responses as they generate", isOn: $streamingEnabled)
                    }

                    // Privacy & Security
                    SettingsSection(title: "Privacy & Security", icon: "lock.fill") {
                        SettingsToggle(title: "Face ID lock", subtitle: "Require Face ID to open", isOn: $showBiometrics)
                        NavigationLink(value: AppPath.memory) {
                            SettingsRow(title: "Memory", subtitle: "\(appState.memories.count) items")
                        }
                        .buttonStyle(.plain)
                    }

                    // iCloud
                    SettingsSection(title: "iCloud", icon: "icloud.fill") {
                        SettingsToggle(title: "iCloud Sync", subtitle: "Sync conversations across devices", isOn: $iCloudSync)
                    }

                    // Tools
                    SettingsSection(title: "Tools & Integrations", icon: "puzzlepiece.fill") {
                        NavigationLink(value: AppPath.promptLibrary) {
                            SettingsRow(title: "Prompt Library", subtitle: "Manage your prompts")
                        }
                        .buttonStyle(.plain)
                        NavigationLink(value: AppPath.marketplace) {
                            SettingsRow(title: "Marketplace", subtitle: "Plugins and extensions")
                        }
                        .buttonStyle(.plain)
                    }

                    // About
                    SettingsSection(title: "About", icon: "info.circle.fill") {
                        SettingsRow(title: "Version", subtitle: "1.0.0 (Build 1)")
                        SettingsRow(title: "Terms of Service", subtitle: nil)
                        SettingsRow(title: "Privacy Policy", subtitle: nil)
                    }

                    Color.clear.frame(height: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
        }
        .ignoresSafeArea()
        .toolbarVisibility(.hidden, for: .navigationBar)
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Label(title, systemImage: icon)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.5))
                .padding(.horizontal, 4)
                .padding(.bottom, 8)

            VStack(spacing: 0) {
                content()
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
            }
            .glassCard(cornerRadius: 18, padding: 0)
        }
    }
}

struct SettingsToggle: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.weight(.medium)).foregroundStyle(.white)
                Text(subtitle).font(.caption).foregroundStyle(.white.opacity(0.45))
            }
            Spacer()
            Toggle("", isOn: $isOn).labelsHidden().tint(.blue)
        }
        .padding(.vertical, 4)
    }
}

struct SettingsRow: View {
    let title: String
    let subtitle: String?

    var body: some View {
        HStack {
            Text(title).font(.subheadline.weight(.medium)).foregroundStyle(.white)
            Spacer()
            if let subtitle {
                Text(subtitle).font(.caption).foregroundStyle(.white.opacity(0.4))
            }
            Image(systemName: "chevron.right").font(.caption).foregroundStyle(.white.opacity(0.25))
        }
        .padding(.vertical, 4)
    }
}
