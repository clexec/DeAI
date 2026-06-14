import SwiftUI

struct PromptLibraryView: View {
    @Environment(AppState.self) private var appState
    @State private var searchText = ""
    @State private var selectedCategory = "All"
    @State private var isAddingPrompt = false
    @State private var newPromptTitle = ""
    @State private var newPromptContent = ""

    let categories = ["All", "Writing", "Coding", "Research", "Business", "Creative", "Education"]

    var filteredPrompts: [FavoritePrompt] {
        appState.favoritePrompts.filter { prompt in
            searchText.isEmpty ||
            prompt.title.localizedCaseInsensitiveContains(searchText) ||
            prompt.content.localizedCaseInsensitiveContains(searchText)
        }
    }

    let builtInPrompts: [(title: String, content: String, category: String)] = [
        ("Expert Explainer", "Explain [topic] as if I'm an expert in the field. Use precise terminology and skip basic explanations.", "Education"),
        ("Code Reviewer", "Review this code for bugs, performance issues, and best practices. Provide specific suggestions with examples.", "Coding"),
        ("Meeting Summarizer", "Summarize the following meeting notes into: key decisions, action items (with owners), and open questions.", "Business"),
        ("Creative Story Starter", "Write the opening paragraph of a [genre] story set in [setting]. Make it immediately gripping.", "Creative"),
        ("Research Synthesizer", "Synthesize information about [topic] from multiple angles: historical context, current state, future implications.", "Research"),
        ("Email Refiner", "Rewrite this email to be more professional, concise, and persuasive while maintaining the core message.", "Writing"),
    ]

    var body: some View {
        ZStack {
            AnimatedBackground()

            VStack(spacing: 0) {
                HStack {
                    Text("Prompt Library")
                        .font(.title.weight(.bold))
                        .foregroundStyle(.white)
                    Spacer()
                    Button {
                        isAddingPrompt = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.body.weight(.semibold))
                            .frame(width: 36, height: 36)
                            .foregroundStyle(.white)
                            .glassCircle(interactive: true)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                HStack(spacing: 10) {
                    Image(systemName: "magnifyingglass").foregroundStyle(.white.opacity(0.5))
                    TextField("", text: $searchText, prompt: Text("Search prompts…").foregroundStyle(.white.opacity(0.4)))
                        .foregroundStyle(.white).autocorrectionDisabled()
                }
                .padding(.horizontal, 14).padding(.vertical, 11)
                .glassCard(cornerRadius: 14)
                .padding(.horizontal, 20).padding(.top, 12)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(categories, id: \.self) { cat in
                            Button(cat) { withAnimation(.smooth) { selectedCategory = cat } }
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(selectedCategory == cat ? .white : .white.opacity(0.55))
                                .padding(.horizontal, 14).padding(.vertical, 8)
                                .glassCapsule(tint: selectedCategory == cat ? .cyan : nil)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.top, 10)

                ScrollView {
                    LazyVStack(spacing: 10) {
                        // Built-in prompts
                        SectionHeader(title: "Built-in Prompts", icon: "sparkles")
                            .padding(.horizontal, 20)
                            .padding(.top, 8)

                        ForEach(builtInPrompts, id: \.title) { prompt in
                            PromptRow(title: prompt.title, content: prompt.content, category: prompt.category, isBuiltIn: true) { }
                                .padding(.horizontal, 20)
                        }

                        // User prompts
                        if !filteredPrompts.isEmpty {
                            SectionHeader(title: "My Prompts", icon: "person.fill")
                                .padding(.horizontal, 20)
                                .padding(.top, 12)

                            ForEach(filteredPrompts) { prompt in
                                PromptRow(title: prompt.title, content: prompt.content, category: prompt.category, isBuiltIn: false) {
                                    appState.favoritePrompts.removeAll { $0.id == prompt.id }
                                }
                                .padding(.horizontal, 20)
                            }
                        }

                        Color.clear.frame(height: 40)
                    }
                    .padding(.top, 10)
                }
            }
        }
        .ignoresSafeArea()
        .toolbarVisibility(.hidden, for: .navigationBar)
        .sheet(isPresented: $isAddingPrompt) { addPromptSheet }
    }

    private var addPromptSheet: some View {
        ZStack {
            AnimatedBackground()
            VStack(spacing: 16) {
                Text("New Prompt")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.top, 28)
                VStack(spacing: 10) {
                    TextField("", text: $newPromptTitle, prompt: Text("Prompt title").foregroundStyle(.white.opacity(0.4)))
                        .foregroundStyle(.white)
                        .padding(14)
                        .glassCard(cornerRadius: 14)
                    TextEditor(text: $newPromptContent)
                        .foregroundStyle(.white)
                        .scrollContentBackground(.hidden)
                        .frame(height: 120)
                        .padding(14)
                        .glassCard(cornerRadius: 14)
                }
                .padding(.horizontal, 20)
                Spacer()
                Button("Save Prompt") {
                    let prompt = FavoritePrompt(title: newPromptTitle, content: newPromptContent)
                    appState.favoritePrompts.append(prompt)
                    newPromptTitle = ""; newPromptContent = ""
                    isAddingPrompt = false
                }
                .buttonStyle(.glassProminent)
                .disabled(newPromptTitle.isEmpty || newPromptContent.isEmpty)
                .padding(.horizontal, 20).padding(.bottom, 34)
            }
        }
        .ignoresSafeArea()
    }
}

private struct PromptRow: View {
    let title: String
    let content: String
    let category: String
    let isBuiltIn: Bool
    let onDelete: () -> Void

    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                        Text(category)
                            .font(.caption2)
                            .foregroundStyle(.cyan.opacity(0.8))
                    }
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.4))
                }
                .padding(.horizontal, 14).padding(.vertical, 12)
            }

            if isExpanded {
                VStack(alignment: .leading, spacing: 10) {
                    Divider().overlay(.white.opacity(0.1))
                    Text(content)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.8))
                        .padding(.horizontal, 14)
                    HStack(spacing: 10) {
                        Button {
                            UIPasteboard.general.string = content
                        } label: {
                            Label("Copy", systemImage: "doc.on.doc")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(.white.opacity(0.7))
                                .padding(.horizontal, 12).padding(.vertical, 6)
                                .glassCapsule()
                        }
                        if !isBuiltIn {
                            Button(role: .destructive) { onDelete() } label: {
                                Label("Delete", systemImage: "trash")
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(.red.opacity(0.8))
                                    .padding(.horizontal, 12).padding(.vertical, 6)
                                    .glassCapsule(tint: .red)
                            }
                        }
                    }
                    .padding(.horizontal, 14).padding(.bottom, 12)
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .glassCard(cornerRadius: 16, padding: 0)
        .clipped()
    }
}
