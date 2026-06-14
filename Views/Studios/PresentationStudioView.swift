import SwiftUI

struct PresentationStudioView: View {
    @Environment(AppState.self) private var appState
    @State private var topic = ""
    @State private var slideCount = 8
    @State private var selectedTheme = 0
    @State private var isGenerating = false
    @State private var generatedSlides: [SlideData] = []
    @State private var selectedSlide: SlideData?
    @FocusState private var topicFocused: Bool

    let themes = ["Professional", "Creative", "Minimal", "Dark", "Gradient"]

    var body: some View {
        ZStack {
            AnimatedBackground()

            VStack(spacing: 0) {
                HStack {
                    Text("Presentation Studio")
                        .font(.title.weight(.bold))
                        .foregroundStyle(.white)
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                ScrollView {
                    if generatedSlides.isEmpty {
                        generateForm
                    } else {
                        slideDeck
                    }
                }
            }
        }
        .ignoresSafeArea()
        .toolbarVisibility(.hidden, for: .navigationBar)
        .sheet(item: $selectedSlide) { slide in
            SlideEditorSheet(slide: slide)
        }
    }

    private var generateForm: some View {
        VStack(spacing: 14) {
            GlassCard(cornerRadius: 18) {
                VStack(alignment: .leading, spacing: 10) {
                    Label("Topic", systemImage: "rectangle.stack.fill").font(.caption.weight(.semibold)).foregroundStyle(.white.opacity(0.5))
                    TextField("", text: $topic, prompt: Text("e.g. Climate change solutions").foregroundStyle(.white.opacity(0.35)), axis: .vertical)
                        .foregroundStyle(.white)
                        .focused($topicFocused)
                        .lineLimit(3)
                }
            }

            GlassCard(cornerRadius: 18) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Label("Slides", systemImage: "number.circle").font(.caption.weight(.semibold)).foregroundStyle(.white.opacity(0.5))
                        Spacer()
                        Text("\(slideCount)")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(.white)
                    }
                    Slider(value: .init(
                        get: { Double(slideCount) },
                        set: { slideCount = Int($0) }
                    ), in: 4...20, step: 1)
                    .tint(.purple)
                }
            }

            GlassCard(cornerRadius: 18) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Theme").font(.caption.weight(.semibold)).foregroundStyle(.white.opacity(0.5))
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(themes.indices, id: \.self) { i in
                                Button(themes[i]) {
                                    withAnimation(.smooth) { selectedTheme = i }
                                }
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(selectedTheme == i ? .white : .white.opacity(0.55))
                                .padding(.horizontal, 14).padding(.vertical, 8)
                                .glassCapsule(tint: selectedTheme == i ? .purple : nil)
                            }
                        }
                    }
                }
            }

            Button {
                topicFocused = false
                generatePresentation()
            } label: {
                HStack(spacing: 10) {
                    if isGenerating {
                        ProgressView().tint(.white)
                        Text("Creating \(slideCount) slides…")
                    } else {
                        Image(systemName: "wand.and.sparkles.inverse")
                        Text("Generate Presentation")
                    }
                }
                .font(.body.weight(.semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .glassCard(cornerRadius: 18, tint: .purple)
            }
            .disabled(topic.isEmpty || isGenerating)

            Color.clear.frame(height: 30)
        }
        .padding(.horizontal, 20)
        .padding(.top, 14)
    }

    private var slideDeck: some View {
        VStack(spacing: 14) {
            HStack {
                Text("\(generatedSlides.count) slides")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                Spacer()
                Button("Reset") {
                    withAnimation { generatedSlides = [] }
                }
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.5))

                Button {
                    // Export
                } label: {
                    Label("Export", systemImage: "square.and.arrow.up")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14).padding(.vertical, 8)
                        .glassCapsule(tint: .purple)
                }
            }

            LazyVStack(spacing: 10) {
                ForEach(generatedSlides.indices, id: \.self) { i in
                    SlideThumbnail(slide: generatedSlides[i], index: i + 1) {
                        selectedSlide = generatedSlides[i]
                    }
                }
            }
            Color.clear.frame(height: 30)
        }
        .padding(.horizontal, 20)
        .padding(.top, 14)
    }

    private func generatePresentation() {
        isGenerating = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            generatedSlides = (0..<slideCount).map { i in
                SlideData(
                    index: i,
                    title: i == 0 ? topic : "\(topic): Part \(i)",
                    content: "Key points and insights about \(topic) — slide \(i + 1)",
                    notes: "Speaker notes for slide \(i + 1)"
                )
            }
            isGenerating = false
        }
    }
}

struct SlideData: Identifiable {
    let id = UUID()
    let index: Int
    var title: String
    var content: String
    var notes: String
}

private struct SlideThumbnail: View {
    let slide: SlideData
    let index: Int
    let onEdit: () -> Void

    var body: some View {
        Button(action: onEdit) {
            HStack(spacing: 14) {
                // Mini slide preview
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(colors: [.purple.opacity(0.4), .blue.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                        .frame(width: 80, height: 54)
                    VStack(spacing: 2) {
                        Text("\(index)")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.white.opacity(0.5))
                        Text(slide.title)
                            .font(.system(size: 7, weight: .semibold))
                            .foregroundStyle(.white)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                    }
                    .padding(4)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("Slide \(index): \(slide.title)")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text(slide.content)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                        .lineLimit(2)
                }
                Spacer()
                Image(systemName: "pencil")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.4))
            }
            .padding(14)
            .glassCard(cornerRadius: 16)
        }
        .buttonStyle(.plain)
    }
}

private struct SlideEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    var slide: SlideData
    @State private var title: String
    @State private var content: String
    @State private var notes: String

    init(slide: SlideData) {
        self.slide = slide
        _title = State(initialValue: slide.title)
        _content = State(initialValue: slide.content)
        _notes = State(initialValue: slide.notes)
    }

    var body: some View {
        ZStack {
            AnimatedBackground()
            VStack(spacing: 16) {
                HStack {
                    Text("Edit Slide")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)
                    Spacer()
                    Button("Done") { dismiss() }
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16).padding(.vertical, 8)
                        .glassCapsule(interactive: true)
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)

                VStack(spacing: 12) {
                    TextField("", text: $title, prompt: Text("Title").foregroundStyle(.white.opacity(0.4)))
                        .foregroundStyle(.white)
                        .font(.headline)
                        .padding(14)
                        .glassCard(cornerRadius: 14)

                    TextEditor(text: $content)
                        .foregroundStyle(.white)
                        .scrollContentBackground(.hidden)
                        .frame(height: 120)
                        .padding(14)
                        .glassCard(cornerRadius: 14)

                    VStack(alignment: .leading, spacing: 6) {
                        Label("Speaker Notes", systemImage: "note.text")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.5))
                        TextEditor(text: $notes)
                            .foregroundStyle(.white.opacity(0.8))
                            .scrollContentBackground(.hidden)
                            .frame(height: 80)
                    }
                    .padding(14)
                    .glassCard(cornerRadius: 14)
                }
                .padding(.horizontal, 20)

                Spacer()
            }
        }
        .ignoresSafeArea()
    }
}
