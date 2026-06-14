import Foundation
import SwiftUI

enum AIProviderType: String, CaseIterable, Identifiable, Codable {
    case openAI      = "OpenAI"
    case claude      = "Claude"
    case gemini      = "Gemini"
    case deepSeek    = "DeepSeek"
    case openRouter  = "OpenRouter"
    case grok        = "Grok"
    case mistral     = "Mistral"
    case cohere      = "Cohere"
    case azureOpenAI = "Azure OpenAI"
    case ollama      = "Ollama"
    case lmStudio    = "LM Studio"
    case custom      = "Custom"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .openAI:      return "circle.hexagongrid.fill"
        case .claude:      return "sparkles"
        case .gemini:      return "star.fill"
        case .deepSeek:    return "water.waves"
        case .openRouter:  return "arrow.triangle.2.circlepath"
        case .grok:        return "bolt.fill"
        case .mistral:     return "wind"
        case .cohere:      return "waveform"
        case .azureOpenAI: return "cloud.fill"
        case .ollama:      return "desktopcomputer"
        case .lmStudio:    return "cpu.fill"
        case .custom:      return "gear"
        }
    }

    var brandColor: Color {
        switch self {
        case .openAI:      return Color(red: 0.07, green: 0.73, blue: 0.54)
        case .claude:      return Color(red: 0.90, green: 0.45, blue: 0.20)
        case .gemini:      return Color(red: 0.26, green: 0.52, blue: 0.96)
        case .deepSeek:    return Color(red: 0.00, green: 0.78, blue: 0.88)
        case .openRouter:  return Color(red: 0.55, green: 0.28, blue: 0.95)
        case .grok:        return Color(red: 0.95, green: 0.75, blue: 0.10)
        case .mistral:     return Color(red: 0.85, green: 0.20, blue: 0.30)
        case .cohere:      return Color(red: 0.10, green: 0.70, blue: 0.70)
        case .azureOpenAI: return Color(red: 0.00, green: 0.47, blue: 0.84)
        case .ollama:      return Color(red: 0.50, green: 0.50, blue: 0.55)
        case .lmStudio:    return Color(red: 0.38, green: 0.33, blue: 0.93)
        case .custom:      return Color(red: 0.60, green: 0.60, blue: 0.65)
        }
    }

    var defaultBaseURL: String {
        switch self {
        case .openAI:      return "https://api.openai.com/v1"
        case .claude:      return "https://api.anthropic.com"
        case .gemini:      return "https://generativelanguage.googleapis.com/v1beta"
        case .deepSeek:    return "https://api.deepseek.com/v1"
        case .openRouter:  return "https://openrouter.ai/api/v1"
        case .grok:        return "https://api.x.ai/v1"
        case .mistral:     return "https://api.mistral.ai/v1"
        case .cohere:      return "https://api.cohere.ai/v1"
        case .azureOpenAI: return ""
        case .ollama:      return "http://localhost:11434/v1"
        case .lmStudio:    return "http://localhost:1234/v1"
        case .custom:      return ""
        }
    }

    var defaultModels: [AIModel] {
        switch self {
        case .openAI:
            return [
                AIModel(id: "gpt-4o",        name: "GPT-4o",       providerType: .openAI,  description: "Most capable multimodal model", supportsVision: true),
                AIModel(id: "gpt-4o-mini",   name: "GPT-4o Mini",  providerType: .openAI,  description: "Fast, affordable intelligence",  supportsVision: true),
                AIModel(id: "o3",            name: "o3",            providerType: .openAI,  description: "Advanced reasoning",              supportsReasoning: true),
                AIModel(id: "o4-mini",       name: "o4-mini",       providerType: .openAI,  description: "Fast reasoning model",            supportsReasoning: true),
            ]
        case .claude:
            return [
                AIModel(id: "claude-opus-4-8",            name: "Claude Opus 4",    providerType: .claude, description: "Most intelligent Claude",     supportsReasoning: true, supportsVision: true, contextWindow: 200_000),
                AIModel(id: "claude-sonnet-4-6",          name: "Claude Sonnet 4.6",providerType: .claude, description: "Best balance of speed",       supportsReasoning: true, supportsVision: true, contextWindow: 200_000),
                AIModel(id: "claude-haiku-4-5-20251001",  name: "Claude Haiku 4.5", providerType: .claude, description: "Fastest Claude model",        supportsVision: true, contextWindow: 200_000),
            ]
        case .gemini:
            return [
                AIModel(id: "gemini-2.5-pro",   name: "Gemini 2.5 Pro",   providerType: .gemini, description: "Most capable Gemini", supportsReasoning: true, supportsVision: true, contextWindow: 1_000_000),
                AIModel(id: "gemini-2.5-flash", name: "Gemini 2.5 Flash", providerType: .gemini, description: "Fast and efficient",                      supportsVision: true, contextWindow: 1_000_000),
            ]
        case .deepSeek:
            return [
                AIModel(id: "deepseek-chat",     name: "DeepSeek Chat",     providerType: .deepSeek, description: "Advanced reasoning at low cost"),
                AIModel(id: "deepseek-reasoner", name: "DeepSeek Reasoner", providerType: .deepSeek, description: "Deep thinking model", supportsReasoning: true),
            ]
        case .grok:
            return [
                AIModel(id: "grok-3",      name: "Grok 3",      providerType: .grok, description: "Most capable Grok model"),
                AIModel(id: "grok-3-mini", name: "Grok 3 Mini", providerType: .grok, description: "Fast, efficient Grok"),
            ]
        case .mistral:
            return [
                AIModel(id: "mistral-large-latest", name: "Mistral Large", providerType: .mistral, description: "Most capable Mistral model"),
                AIModel(id: "mistral-small-latest", name: "Mistral Small", providerType: .mistral, description: "Efficient Mistral model"),
            ]
        default:
            return []
        }
    }
}

struct AIModel: Identifiable, Codable, Hashable {
    let id: String
    var name: String
    var providerType: AIProviderType
    var description: String
    var supportsReasoning: Bool = false
    var supportsVision: Bool = false
    var contextWindow: Int = 128_000
    var isCustom: Bool = false
    var connectionStatus: ConnectionStatus = .unknown

    enum ConnectionStatus: String, Codable {
        case connected, disconnected, unknown, checking

        var color: Color {
            switch self {
            case .connected:    return .green
            case .disconnected: return .red
            case .unknown:      return .gray
            case .checking:     return .yellow
            }
        }

        var label: String {
            switch self {
            case .connected:    return "Connected"
            case .disconnected: return "Disconnected"
            case .unknown:      return "Not tested"
            case .checking:     return "Checking…"
            }
        }
    }
}

struct AIProvider: Identifiable, Codable {
    var id: UUID = UUID()
    var type: AIProviderType
    var apiKey: String = ""
    var baseURL: String
    var isEnabled: Bool = true
    var customName: String = ""
    var models: [AIModel] = []

    var displayName: String { customName.isEmpty ? type.rawValue : customName }

    init(type: AIProviderType) {
        self.type = type
        self.baseURL = type.defaultBaseURL
        self.models = type.defaultModels
    }
}
