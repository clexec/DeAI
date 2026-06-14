import Foundation

struct MemoryItem: Identifiable, Codable {
    var id: UUID = UUID()
    var content: String
    var isEnabled: Bool = true
    var isPaused: Bool = false
    var projectID: UUID?
    var tags: [String] = []
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    var preview: String {
        String(content.prefix(120))
    }
}

struct FavoriteItem: Identifiable, Codable {
    var id: UUID = UUID()
    var type: FavoriteType
    var title: String
    var content: String
    var folderID: UUID?
    var createdAt: Date = Date()

    enum FavoriteType: String, Codable {
        case conversation, prompt, message, image, file

        var iconName: String {
            switch self {
            case .conversation: return "bubble.left.and.bubble.right"
            case .prompt:       return "text.quote"
            case .message:      return "bubble.right"
            case .image:        return "photo"
            case .file:         return "doc"
            }
        }
    }
}

struct FavoriteFolder: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var iconName: String = "folder.fill"
    var colorHex: String = "#007AFF"
    var createdAt: Date = Date()
}

struct DownloadedContent: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var type: ContentType
    var size: Int64 = 0
    var createdAt: Date = Date()
    var thumbnailURL: URL?

    enum ContentType: String, Codable, CaseIterable {
        case image, document, presentation, website, app, code, pdf

        var iconName: String {
            switch self {
            case .image:        return "photo"
            case .document:     return "doc.text"
            case .presentation: return "rectangle.stack"
            case .website:      return "globe"
            case .app:          return "apps.iphone"
            case .code:         return "curlybraces"
            case .pdf:          return "doc.richtext"
            }
        }
    }
}
