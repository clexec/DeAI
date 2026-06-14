import Foundation
import SwiftUI

enum TaskStatus: String, Codable, CaseIterable {
    case notStarted, running, completed, failed

    var iconName: String {
        switch self {
        case .notStarted: return "circle"
        case .running:    return "circle.dotted"
        case .completed:  return "checkmark.circle.fill"
        case .failed:     return "xmark.circle.fill"
        }
    }

    var statusColor: Color {
        switch self {
        case .notStarted: return Color(white: 0.5)
        case .running:    return .blue
        case .completed:  return .green
        case .failed:     return .red
        }
    }

    var label: String {
        switch self {
        case .notStarted: return "Not started"
        case .running:    return "Running"
        case .completed:  return "Completed"
        case .failed:     return "Failed"
        }
    }
}

struct TaskLog: Identifiable, Codable {
    var id: UUID = UUID()
    var timestamp: Date = Date()
    var message: String
    var level: LogLevel = .info

    enum LogLevel: String, Codable {
        case info, warning, error, success

        var color: Color {
            switch self {
            case .info:    return .white.opacity(0.7)
            case .warning: return .yellow
            case .error:   return .red
            case .success: return .green
            }
        }

        var prefix: String {
            switch self {
            case .info:    return "ℹ"
            case .warning: return "⚠"
            case .error:   return "✗"
            case .success: return "✓"
            }
        }
    }
}

struct AgentTask: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var description: String = ""
    var status: TaskStatus = .notStarted
    var progress: Double = 0.0

    var subtasks: [AgentTask] = []
    var logs: [TaskLog] = []
    var executedFiles: [String] = []
    var visitedURLs: [String] = []
    var generatedOutputs: [String] = []

    var startedAt: Date?
    var completedAt: Date?
    var isExpanded: Bool = false
}
