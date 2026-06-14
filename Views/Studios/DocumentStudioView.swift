import SwiftUI

struct DocumentStudioView: View {
    @Environment(AppState.self) private var appState
    @State private var prompt = ""
    @State private var selectedType = 0
    @State private var isGenerating = false
    @State private var generatedContent = ""
    @State private var documentTitle = ""
    @FocusState private var promptFocused: Bool

    let docTypes = ["Document", "Report", "Contract", "Article", "Email", "Proposal"]

    var body: some View {
        ZStack {
            AnimatedBackground()

            VStack(spacing: 0) {
                HStack {
                    Text("Document Studio")
                        .font(.title.weight(.bold))
                        .foregroundStyle(.white)
                    Spacer()
                    if !generatedContent.isEmpty {
                        Button {
                            // Export
                        } label: {
                            Label("Export", systemImage: "square.and.arrow.up")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 14).padding(.vertical, 8)
                                .glassCapsule(tint: .blue)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                if generatedContent.isEmpty {
                    generateForm
                } else {
                    editorView
                }
            }
        }
        .ignoresSafeArea()
        .toolbarVisibility(.hidden, for: .navigationBar)
    }

    private var generateForm: some View {
        ScrollView {
            VStack(spacing: 14) {
                // Document type
                GlassCard(cornerRadius: 18) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Document Type").font(.caption.weight(.semibold)).foregroundStyle(.white.opacity(0.5))
                        LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 3), spacing: 8) {
                            ForEach(docTypes.indices, id: \.self) { i in
                                Button(docTypes[i]) {
                                    withAnimation(.smooth) { selectedType = i }
                                }
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(selectedType == i ? .white : .white.opacity(0.55))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .glassCard(cornerRadius: 12, tint: selectedType == i ? .blue : nil)
                            }
                        }
                    }
                }

                // Prompt
                GlassCard(cornerRadius: 18) {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Describe the document", systemImage: "text.alignleft")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.5))
                        ZStack(alignment: .topLeading) {
                            if prompt.isEmpty {
                                Text("e.g. Write a professional proposal for a mobile app development project…")
                                    .font(.body)
                                    .foregroundStyle(.white.opacity(0.3))
                                    .padding(.top, 2)
                                    .allowsHitTesting(false)
                            }
                            TextEditor(text: $prompt)
                                .foregroundStyle(.white)
                                .scrollContentBackground(.hidden)
                                .frame(minHeight: 100)
                                .focused($promptFocused)
                        }
                    }
                }

                Button {
                    promptFocused = false
                    generateDocument()
                } label: {
                    HStack(spacing: 10) {
                        if isGenerating {
                            ProgressView().tint(.white)
                            Text("Writing \(docTypes[selectedType])…")
                        } else {
                            Image(systemName: "doc.badge.plus")
                            Text("Generate \(docTypes[selectedType])")
                        }
                    }
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .glassCard(cornerRadius: 18, tint: .blue)
                }
                .disabled(prompt.isEmpty || isGenerating)

                Color.clear.frame(height: 30)
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)
        }
    }

    private var editorView: some View {
        VStack(spacing: 0) {
            // Document title
            TextField("Document title", text: $documentTitle)
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)

            Divider().overlay(.white.opacity(0.1))

            // Content editor
            ScrollView {
                TextEditor(text: $generatedContent)
                    .foregroundStyle(.white)
                    .scrollContentBackground(.hidden)
                    .font(.body)
                    .lineSpacing(6)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .frame(minHeight: 400)
            }

            // AI assist bar
            HStack(spacing: 10) {
                ForEach(["Continue writing", "Summarize", "Translate", "Improve"], id: \.self) { action in
                    Button(action) {
                        // AI action
                    }
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.7))
                    .padding(.horizontal, 10).padding(.vertical, 6)
                    .glassCapsule()
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .glassCard(cornerRadius: 0)
        }
    }

    private func generateDocument() {
        isGenerating = true
        documentTitle = "\(docTypes[selectedType]): \(String(prompt.prefix(40)))"
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            generatedContent = """
            \(documentTitle)

            Executive Summary
            This document provides a comprehensive overview of \(prompt.prefix(100)).

            Introduction
            The purpose of this \(docTypes[selectedType].lowercased()) is to outline key aspects and recommendations related to the subject matter at hand.

            Key Points
            • Strategic alignment with organizational goals
            • Measurable outcomes and success criteria
            • Implementation timeline and milestones
            • Resource allocation and budget considerations

            Conclusion
            Based on the analysis presented, we recommend moving forward with the proposed approach while maintaining flexibility for iterative improvements.
            """
            isGenerating = false
        }
    }
}
