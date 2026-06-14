import Foundation
import SwiftUI

enum MessageRole: String, Codable {
    case user, assistant, system, tool
}

enum MessageStatus: String, Codable {
    case sending, sent, error
}

struct MessageTranslation: Identifiable, Codable {
    var id: UUID = UUID()
    var targetLanguage: String
    var translatedText: String
}

struct ReasoningData: Codable {
    var objective: String = ""
    var assumptions: [String] = []
    var analysisSteps: [String] = []
    var findings: [String] = []
    var conclusion: String = ""
    var thinkingTokensUsed: Int = 0
}

struct MessageAttachment: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var type: AttachmentType
    var size: Int64 = 0

    enum AttachmentType: String, Codable {
        case image, pdf, document, audio, video, file, website

        var iconName: String {
            switch self {
            case .image:    return "photo"
            case .pdf:      return "doc.richtext"
            case .document: return "doc.text"
            case .audio:    return "waveform"
            case .video:    return "video"
            case .file:     return "doc"
            case .website:  return "globe"
            }
        }
    }
}

struct ToolCard: Identifiable, Codable {
    var id: UUID = UUID()
    var toolType: ToolType
    var status: ExecutionStatus = .running
    var detail: String = ""
    var result: String?

    enum ToolType: String, Codable {
        case browser          = "Using Browser"
        case python           = "Running Python"
        case terminal         = "Using Terminal"
        case analyzeWebsite   = "Analyzing Website"
        case readPDF          = "Reading PDF"
        case generateImage    = "Generating Image"
        case createPresentation = "Creating Presentation"
        case buildApp         = "Building Application"
        case writeCode        = "Writing Code"
        case searchWeb        = "Searching Web"

        var iconName: String {
            switch self {
            case .browser:              return "globe"
            case .python:               return "chevron.left.forwardslash.chevron.right"
            case .terminal:             return "terminal"
            case .analyzeWebsite:       return "doc.magnifyingglass"
            case .readPDF:              return "doc.richtext"
            case .generateImage:        return "photo.badge.plus"
            case .createPresentation:   return "rectangle.stack"
            case .buildApp:             return "apps.iphone"
            case .writeCode:            return "curlybraces"
            case .searchWeb:            return "magnifyingglass.circle"
            }
        }

        var cardColor: Color {
            switch self {
            case .browser:              return .blue
            case .python:               return .green
            case .terminal:             return Color(white: 0.5)
            case .analyzeWebsite:       return .orange
            case .readPDF:              return .red
            case .generateImage:        return .purple
            case .createPresentation:   return .yellow
            case .buildApp:             return .cyan
            case .writeCode:            return .teal
            case .searchWeb:            return .indigo
            }
        }
    }

    enum ExecutionStatus: String, Codable {
        case running, completed, failed

        var color: Color {
            switch self {
            case .running:   return .blue
            case .completed: return .green
            case .failed:    return .red
            }
        }
    }
}

struct ChatMessage: Identifiable, Codable {
    var id: UUID = UUID()
    var role: MessageRole
    var content: String
    var timestamp: Date = Date()
    var status: MessageStatus = .sent

    var isLiked: Bool = false
    var isDisliked: Bool = false

    var translation: MessageTranslation?
    var reasoning: ReasoningData?
    var agentTasks: [AgentTask] = []
    var toolCards: [ToolCard] = []
    var attachments: [MessageAttachment] = []
    var generatedImageURL: URL?
}
