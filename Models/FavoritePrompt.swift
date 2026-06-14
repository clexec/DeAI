import Foundation

struct FavoritePrompt: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var content: String
    var category: String = "General"
    var createdAt: Date = Date()
}
