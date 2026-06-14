import Foundation
import SwiftUI

@Observable
final class AppState {
    // Conversations
    var conversations: [Conversation] = []
    var selectedConversationID: UUID?

    // Providers & Models
    var providers: [AIProvider] = AIProviderType.allCases.map { AIProvider(type: $0) }
    var selectedModelID: String = "gpt-4o"
    var selectedProviderType: AIProviderType = .openAI

    // Content
    var projects: [Project] = []
    var memories: [MemoryItem] = []
    var favoriteItems: [FavoriteItem] = []
    var favoriteFolders: [FavoriteFolder] = []
    var downloads: [DownloadedContent] = []

    // Navigation
    var navigationPath: [AppPath] = []
    var isShowingModelSelector = false
    var isShowingChats = false
    var isShowingSettings = false

    // Usage metrics
    var totalTokensUsed: Int = 0
    var totalCost: Double = 0.0
    var usageByModel: [String: Int] = [:]
    var dailyTokenUsage: [Date: Int] = [:]

    // Computed
    var selectedModel: AIModel {
        providers
            .flatMap { $0.models }
            .first { $0.id == selectedModelID }
            ?? AIModel(id: "gpt-4o", name: "GPT-4o", providerType: .openAI, description: "Most capable multimodal model")
    }

    var selectedProvider: AIProvider {
        providers.first { $0.type == selectedProviderType } ?? AIProvider(type: .openAI)
    }

    var activeConversations: [Conversation] {
        conversations.filter { !$0.isArchived }
            .sorted { $0.updatedAt > $1.updatedAt }
    }

    var archivedConversations: [Conversation] {
        conversations.filter { $0.isArchived }
            .sorted { $0.updatedAt > $1.updatedAt }
    }

    var pinnedConversations: [Conversation] {
        conversations.filter { $0.isPinned && !$0.isArchived }
    }

    // MARK: - Conversation management

    @discardableResult
    func createNewConversation(in projectID: UUID? = nil) -> Conversation {
        var conv = Conversation(title: "New Conversation")
        conv.modelID = selectedModelID
        conv.providerType = selectedProviderType
        conv.projectID = projectID
        conversations.insert(conv, at: 0)
        selectedConversationID = conv.id
        return conv
    }

    func deleteConversation(_ id: UUID) {
        conversations.removeAll { $0.id == id }
        if selectedConversationID == id { selectedConversationID = nil }
    }

    func archiveConversation(_ id: UUID) {
        guard let idx = conversations.firstIndex(where: { $0.id == id }) else { return }
        conversations[idx].isArchived = true
        conversations[idx].isPinned = false
    }

    func restoreConversation(_ id: UUID) {
        guard let idx = conversations.firstIndex(where: { $0.id == id }) else { return }
        conversations[idx].isArchived = false
    }

    func togglePin(_ id: UUID) {
        guard let idx = conversations.firstIndex(where: { $0.id == id }) else { return }
        conversations[idx].isPinned.toggle()
    }

    func toggleFavorite(_ id: UUID) {
        guard let idx = conversations.firstIndex(where: { $0.id == id }) else { return }
        conversations[idx].isFavorite.toggle()
    }

    func renameConversation(_ id: UUID, to name: String) {
        guard let idx = conversations.firstIndex(where: { $0.id == id }) else { return }
        conversations[idx].title = name
    }

    func conversation(for id: UUID) -> Conversation? {
        conversations.first { $0.id == id }
    }

    func updateConversation(_ conversation: Conversation) {
        guard let idx = conversations.firstIndex(where: { $0.id == conversation.id }) else { return }
        conversations[idx] = conversation
    }

    // MARK: - Memory

    func addMemory(_ content: String, projectID: UUID? = nil) {
        let item = MemoryItem(content: content, projectID: projectID)
        memories.insert(item, at: 0)
    }

    func deleteMemory(_ id: UUID) {
        memories.removeAll { $0.id == id }
    }

    func toggleMemory(_ id: UUID) {
        guard let idx = memories.firstIndex(where: { $0.id == id }) else { return }
        memories[idx].isEnabled.toggle()
    }
}

enum AppPath: Hashable {
    case home
    case chat(UUID)
    case projects
    case projectDetail(UUID)
    case favorites
    case archive
    case downloads
    case analytics
    case memory
    case settings
    case providerSettings(UUID)
    case browser
    case sandbox
    case imageStudio
    case presentationStudio
    case documentStudio
    case websiteBuilder
    case appBuilder
    case marketplace
    case promptLibrary
}
