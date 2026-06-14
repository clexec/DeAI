import Foundation
import SwiftUI

struct ProjectFile: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var fileType: String
    var size: Int64 = 0
    var createdAt: Date = Date()
}

struct ProjectMemory: Identifiable, Codable {
    var id: UUID = UUID()
    var content: String
    var isEnabled: Bool = true
    var createdAt: Date = Date()
}

struct ProjectAISettings: Codable {
    var modelID: String = "gpt-4o"
    var providerType: AIProviderType = .openAI
    var systemPrompt: String = ""
    var temperature: Double = 0.7
    var maxTokens: Int = 4096
    var reasoningEnabled: Bool = false
}

struct Project: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var description: String = ""
    var iconName: String = "folder.fill"
    var colorHex: String = "#007AFF"

    var files: [ProjectFile] = []
    var memories: [ProjectMemory] = []
    var conversationIDs: [UUID] = []
    var aiSettings: ProjectAISettings = ProjectAISettings()

    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    var displayColor: Color {
        Color(hex: colorHex) ?? .blue
    }
}

extension Color {
    init?(hex: String) {
        var sanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        guard sanitized.count == 6 else { return nil }
        var value: UInt64 = 0
        guard Scanner(string: sanitized).scanHexInt64(&value) else { return nil }
        self.init(
            red:   Double((value >> 16) & 0xFF) / 255,
            green: Double((value >>  8) & 0xFF) / 255,
            blue:  Double( value        & 0xFF) / 255
        )
    }

    func toHex() -> String {
        let ui = UIColor(self)
        var r: CGFloat = 0; var g: CGFloat = 0; var b: CGFloat = 0; var a: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
}
