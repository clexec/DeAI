import Foundation
import SwiftUI

@Observable
final class ChatViewModel {
    var messages: [ChatMessage] = []
    var inputText: String = ""
    var isLoading: Bool = false
    var isAgentMode: Bool = false
    var isRecording: Bool = false
    var showPlusMenu: Bool = false
    var agentTasks: [AgentTask] = []
    var streamingContent: String = ""

    private(set) var conversationID: UUID

    init(conversation: Conversation) {
        self.conversationID = conversation.id
        self.messages = conversation.messages
    }

    // MARK: - Send

    func sendMessage(appState: AppState) {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let userMsg = ChatMessage(role: .user, content: trimmed)
        messages.append(userMsg)
        inputText = ""
        isLoading = true
        showPlusMenu = false

        if needsAgentMode(prompt: trimmed) {
            startAgentMode(prompt: trimmed)
        } else {
            streamResponse(prompt: trimmed, appState: appState)
        }
        syncToAppState(appState: appState)
    }

    // MARK: - Actions

    func translateMessage(_ message: ChatMessage, to language: String = "Russian") {
        guard let idx = messages.firstIndex(where: { $0.id == message.id }) else { return }
        let translated = MessageTranslation(
            targetLanguage: language,
            translatedText: "[Translated to \(language)]: \(message.content)"
        )
        messages[idx].translation = translated
    }

    func toggleLike(_ message: ChatMessage) {
        guard let idx = messages.firstIndex(where: { $0.id == message.id }) else { return }
        messages[idx].isLiked.toggle()
        if messages[idx].isLiked { messages[idx].isDisliked = false }
    }

    func toggleDislike(_ message: ChatMessage) {
        guard let idx = messages.firstIndex(where: { $0.id == message.id }) else { return }
        messages[idx].isDisliked.toggle()
        if messages[idx].isDisliked { messages[idx].isLiked = false }
    }

    func copyMessage(_ message: ChatMessage) {
        UIPasteboard.general.string = message.content
    }

    func regenerateLastResponse(appState: AppState) {
        guard let lastUser = messages.last(where: { $0.role == .user }) else { return }
        if messages.last?.role == .assistant { messages.removeLast() }
        isLoading = true
        streamResponse(prompt: lastUser.content, appState: appState)
    }

    func expandReasoning(for message: ChatMessage) {
        guard let idx = messages.firstIndex(where: { $0.id == message.id }) else { return }
        if messages[idx].reasoning == nil {
            messages[idx].reasoning = ReasoningData(
                objective: "Analyze and respond to the user's request",
                assumptions: ["The user wants a helpful, accurate response"],
                analysisSteps: ["Parsed the request", "Identified key requirements", "Formulated response"],
                findings: ["Request is clear and answerable"],
                conclusion: messages[idx].content
            )
        }
    }

    // MARK: - Private

    private func needsAgentMode(prompt: String) -> Bool {
        let keywords = ["build", "create website", "generate app", "research", "browse", "analyze multiple", "compare websites"]
        return keywords.contains { prompt.lowercased().contains($0) } && prompt.count > 40
    }

    private func startAgentMode(prompt: String) {
        isAgentMode = true
        agentTasks = [
            AgentTask(title: "Analyzing request",        description: "Understanding the task scope"),
            AgentTask(title: "Planning execution",       description: "Creating step-by-step action plan"),
            AgentTask(title: "Gathering information",    description: "Searching and collecting data"),
            AgentTask(title: "Processing results",       description: "Analyzing collected information"),
            AgentTask(title: "Generating output",        description: "Creating the final response"),
        ]

        var assistantMsg = ChatMessage(role: .assistant, content: "")
        assistantMsg.agentTasks = agentTasks
        messages.append(assistantMsg)

        let delays: [Double] = [0.8, 2.0, 3.5, 5.0, 6.5]
        for (i, delay) in delays.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                guard let self else { return }
                if i > 0 { self.completeTask(at: i - 1) }
                if i < self.agentTasks.count { self.startTask(at: i) }
                if i == delays.count - 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                        self.completeTask(at: i)
                        self.finalizeAgentResponse(prompt: prompt)
                    }
                }
                self.syncTasksToLastMessage()
            }
        }
    }

    private func startTask(at index: Int) {
        guard index < agentTasks.count else { return }
        agentTasks[index].status = .running
        agentTasks[index].startedAt = Date()
    }

    private func completeTask(at index: Int) {
        guard index < agentTasks.count else { return }
        agentTasks[index].status = .completed
        agentTasks[index].progress = 1.0
        agentTasks[index].completedAt = Date()
    }

    private func syncTasksToLastMessage() {
        guard let idx = messages.indices.last else { return }
        messages[idx].agentTasks = agentTasks
    }

    private func finalizeAgentResponse(prompt: String) {
        let summary = String(prompt.prefix(60))
        guard let idx = messages.indices.last else { return }
        messages[idx].content = "I've completed your request: "\(summary)…"\n\nAll tasks finished successfully. Here's a comprehensive summary of what was accomplished."
        messages[idx].agentTasks = agentTasks
        isLoading = false
        isAgentMode = false
    }

    private func streamResponse(prompt: String, appState: AppState) {
        var assistantMsg = ChatMessage(role: .assistant, content: "")
        messages.append(assistantMsg)
        let idx = messages.count - 1

        let fullResponse = "I'm \(appState.selectedModel.name) — here to help you.\n\nYou asked: *\(prompt.prefix(80))*\n\nLet me give you a thoughtful, accurate response. De AI combines the most powerful AI models in one beautiful interface. Feel free to ask me anything!"

        var charIndex = fullResponse.startIndex
        func streamNext() {
            guard charIndex < fullResponse.endIndex else {
                isLoading = false
                syncToAppState(appState: appState)
                return
            }
            let nextIndex = fullResponse.index(after: charIndex)
            messages[idx].content += String(fullResponse[charIndex..<nextIndex])
            charIndex = nextIndex
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.012, execute: streamNext)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: streamNext)
    }

    private func syncToAppState(appState: AppState) {
        appState.updateConversation(
            (appState.conversation(for: conversationID) ?? Conversation(title: "Chat"))
                |> { var c = $0; c.messages = messages; c.updatedAt = Date(); return c }
        )
    }
}

infix operator |>: AdditionPrecedence
func |> <T>(value: T, transform: (T) -> T) -> T { transform(value) }
