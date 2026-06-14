import Foundation

struct Conversation: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var messages: [ChatMessage] = []
    var providerType: AIProviderType = .openAI
    var modelID: String = "gpt-4o"
    var systemPrompt: String = ""

    var isArchived: Bool = false
    var isFavorite: Bool = false
    var isPinned: Bool = false

    var projectID: UUID?

    var tokenCount: Int = 0
    var estimatedCost: Double = 0.0

    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    var preview: String {
        messages.last?.content.prefix(100).description ?? "No messages yet"
    }

    var lastMessageDate: Date {
        messages.last?.timestamp ?? createdAt
    }
}
