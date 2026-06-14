import SwiftUI

struct ProviderSettingsView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    let provider: AIProvider

    @State private var apiKey = ""
    @State private var baseURL = ""
    @State private var isTesting = false
    @State private var testResult: Bool?
    @State private var showAPIKey = false

    var body: some View {
        ZStack {
            AnimatedBackground()

            ScrollView {
                VStack(spacing: 16) {
                    // Provider header
                    HStack(spacing: 14) {
                        ProviderBadge(provider: provider.type, size: 52)
                            .shadow(color: provider.type.brandColor.opacity(0.4), radius: 12)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(provider.displayName)
                                .font(.title2.weight(.bold))
                                .foregroundStyle(.white)
                            Text(provider.type.defaultBaseURL.isEmpty ? "Local endpoint" : "Cloud provider")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.5))
                        }
                        Spacer()
                    }
                    .padding(.top, 8)

                    // API Key
                    GlassCard(cornerRadius: 18) {
                        VStack(alignment: .leading, spacing: 14) {
                            Label("API Key", systemImage: "key.fill")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.white.opacity(0.5))

                            HStack {
                                Group {
                                    if showAPIKey {
                                        TextField("", text: $apiKey, prompt: Text("Enter API key…").foregroundStyle(.white.opacity(0.4)))
                                    } else {
                                        SecureField("", text: $apiKey, prompt: Text("Enter API key…").foregroundStyle(.white.opacity(0.4)))
                                    }
                                }
                                .foregroundStyle(.white)
                                .font(.system(.body, design: .monospaced))
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)

                                Button {
                                    showAPIKey.toggle()
                                } label: {
                                    Image(systemName: showAPIKey ? "eye.slash" : "eye")
                                        .foregroundStyle(.white.opacity(0.4))
                                }
                            }
                            .padding(12)
                            .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 10))
                        }
                    }

                    // Base URL
                    GlassCard(cornerRadius: 18) {
                        VStack(alignment: .leading, spacing: 10) {
                            Label("Base URL", systemImage: "globe")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.white.opacity(0.5))
                            TextField("", text: $baseURL, prompt: Text(provider.type.defaultBaseURL).foregroundStyle(.white.opacity(0.3)))
                                .foregroundStyle(.white)
                                .font(.system(.body, design: .monospaced))
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                                .padding(12)
                                .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 10))
                        }
                    }

                    // Test connection
                    Button {
                        testConnection()
                    } label: {
                        HStack(spacing: 10) {
                            if isTesting {
                                ProgressView().tint(.white).scaleEffect(0.9)
                                Text("Testing connection…")
                            } else if let result = testResult {
                                Image(systemName: result ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundStyle(result ? .green : .red)
                                Text(result ? "Connected successfully" : "Connection failed")
                            } else {
                                Image(systemName: "network")
                                Text("Test Connection")
                            }
                        }
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .glassCapsule(interactive: true)
                    }

                    // Models list
                    if !provider.models.isEmpty {
                        SettingsSection(title: "Available Models", icon: "sparkles") {
                            ForEach(provider.models) { model in
                                HStack(spacing: 12) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(model.name)
                                            .font(.subheadline.weight(.medium))
                                            .foregroundStyle(.white)
                                        Text("\(model.contextWindow / 1000)K context")
                                            .font(.caption)
                                            .foregroundStyle(.white.opacity(0.45))
                                    }
                                    Spacer()
                                    StatusDot(status: model.connectionStatus)
                                }
                                .padding(.vertical, 4)
                            }
                        }
                    }

                    // Save
                    Button("Save Settings") {
                        saveSettings()
                        dismiss()
                    }
                    .buttonStyle(.glassProminent)
                    .tint(provider.type.brandColor)
                    .padding(.bottom, 20)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
        }
        .ignoresSafeArea()
        .toolbarVisibility(.hidden, for: .navigationBar)
        .onAppear {
            apiKey = provider.apiKey
            baseURL = provider.baseURL
        }
    }

    private func saveSettings() {
        if let idx = appState.providers.firstIndex(where: { $0.id == provider.id }) {
            appState.providers[idx].apiKey = apiKey
            appState.providers[idx].baseURL = baseURL.isEmpty ? provider.type.defaultBaseURL : baseURL
        }
    }

    private func testConnection() {
        isTesting = true
        testResult = nil
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            isTesting = false
            testResult = !apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }
}
