import Foundation
import SwiftUI

@Observable
final class ProviderViewModel {
    var providers: [AIProvider]
    var isTestingConnection = false
    var connectionTestResults: [UUID: Bool] = [:]
    var isShowingAddProvider = false

    init(providers: [AIProvider]) {
        self.providers = providers
    }

    func updateAPIKey(_ key: String, forProviderID id: UUID) {
        guard let idx = providers.firstIndex(where: { $0.id == id }) else { return }
        providers[idx].apiKey = key
    }

    func updateBaseURL(_ url: String, forProviderID id: UUID) {
        guard let idx = providers.firstIndex(where: { $0.id == id }) else { return }
        providers[idx].baseURL = url
    }

    func toggleProvider(_ id: UUID) {
        guard let idx = providers.firstIndex(where: { $0.id == id }) else { return }
        providers[idx].isEnabled.toggle()
    }

    func testConnection(provider: AIProvider) async {
        isTestingConnection = true
        // Mark all models as checking
        if let idx = providers.firstIndex(where: { $0.id == provider.id }) {
            for midx in providers[idx].models.indices {
                providers[idx].models[midx].connectionStatus = .checking
            }
        }
        try? await Task.sleep(nanoseconds: 1_800_000_000)
        let success = !provider.apiKey.isEmpty
        connectionTestResults[provider.id] = success
        if let idx = providers.firstIndex(where: { $0.id == provider.id }) {
            for midx in providers[idx].models.indices {
                providers[idx].models[midx].connectionStatus = success ? .connected : .disconnected
            }
        }
        isTestingConnection = false
    }

    func addCustomProvider(name: String, baseURL: String, apiKey: String) {
        var provider = AIProvider(type: .custom)
        provider.customName = name
        provider.baseURL = baseURL
        provider.apiKey = apiKey
        providers.append(provider)
    }

    func deleteProvider(_ id: UUID) {
        providers.removeAll { $0.id == id && $0.type == .custom }
    }

    func enabledProviders(for type: AIProviderType) -> AIProvider? {
        providers.first { $0.type == type && $0.isEnabled }
    }

    var allModels: [AIModel] {
        providers.filter { $0.isEnabled }.flatMap { $0.models }
    }
}
