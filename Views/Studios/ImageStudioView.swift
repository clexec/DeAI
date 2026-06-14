import SwiftUI

struct ImageStudioView: View {
    @Environment(AppState.self) private var appState
    @State private var prompt = ""
    @State private var selectedStyle = 0
    @State private var selectedSize = 1
    @State private var isGenerating = false
    @State private var generatedImages: [GeneratedImage] = []
    @State private var selectedTab = 0
    @FocusState private var promptFocused: Bool

    let styles = ["Realistic", "Artistic", "Abstract", "Anime", "3D", "Sketch"]
    let sizes = ["512×512", "1024×1024", "1024×1792", "1792×1024"]

    var body: some View {
        ZStack {
            AnimatedBackground()

            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Image Studio")
                            .font(.title.weight(.bold))
                            .foregroundStyle(.white)
                        Text("AI-powered image creation")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.45))
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                // Tab switcher: Generate / Edit / Gallery
                Picker("", selection: $selectedTab) {
                    Text("Generate").tag(0)
                    Text("Edit").tag(1)
                    Text("Gallery").tag(2)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 20).padding(.top, 12)

                ScrollView {
                    VStack(spacing: 16) {
                        switch selectedTab {
                        case 0: generateTab
                        case 1: editTab
                        default: galleryTab
                        }
                        Color.clear.frame(height: 30)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 14)
                }
            }
        }
        .ignoresSafeArea()
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Generate Tab

    private var generateTab: some View {
        VStack(spacing: 14) {
            // Prompt input
            GlassCard(cornerRadius: 18) {
                VStack(alignment: .leading, spacing: 10) {
                    Label("Prompt", systemImage: "text.cursor")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.5))

                    TextEditor(text: $prompt)
                        .foregroundStyle(.white)
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 80)
                        .focused($promptFocused)

                    if prompt.isEmpty {
                        Text("Describe what you want to create…")
                            .foregroundStyle(.white.opacity(0.3))
                            .allowsHitTesting(false)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .offset(y: -70)
                    }
                }
            }

            // Style picker
            GlassCard(cornerRadius: 18) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Style").font(.caption.weight(.semibold)).foregroundStyle(.white.opacity(0.5))
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(styles.indices, id: \.self) { i in
                                Button(styles[i]) {
                                    withAnimation(.smooth) { selectedStyle = i }
                                }
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(selectedStyle == i ? .white : .white.opacity(0.55))
                                .padding(.horizontal, 14).padding(.vertical, 8)
                                .glassCapsule(tint: selectedStyle == i ? .purple : nil)
                            }
                        }
                    }
                }
            }

            // Size picker
            GlassCard(cornerRadius: 18) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Size").font(.caption.weight(.semibold)).foregroundStyle(.white.opacity(0.5))
                    LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 2), spacing: 8) {
                        ForEach(sizes.indices, id: \.self) { i in
                            Button(sizes[i]) {
                                withAnimation(.smooth) { selectedSize = i }
                            }
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(selectedSize == i ? .white : .white.opacity(0.55))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .glassCard(cornerRadius: 12, tint: selectedSize == i ? .purple : nil)
                        }
                    }
                }
            }

            // Generate button
            Button {
                generateImage()
            } label: {
                HStack(spacing: 10) {
                    if isGenerating {
                        ProgressView().tint(.white)
                        Text("Generating…")
                    } else {
                        Image(systemName: "wand.and.sparkles")
                        Text("Generate Image")
                    }
                }
                .font(.body.weight(.semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .glassCard(cornerRadius: 18, tint: .purple)
            }
            .disabled(prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isGenerating)

            // Generated results
            if !generatedImages.isEmpty {
                generatedResultsGrid
            }
        }
    }

    private var generatedResultsGrid: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Results")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)

            LazyVGrid(columns: [.init(.flexible(), spacing: 10), .init(.flexible(), spacing: 10)], spacing: 10) {
                ForEach(generatedImages) { img in
                    GeneratedImageCard(image: img)
                }
            }
        }
    }

    private var editTab: some View {
        VStack(spacing: 16) {
            // Upload area
            Button { } label: {
                VStack(spacing: 12) {
                    Image(systemName: "photo.badge.plus")
                        .font(.system(size: 40))
                        .foregroundStyle(.purple.opacity(0.7))
                    Text("Upload an image to edit")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.6))
                }
                .frame(maxWidth: .infinity, minHeight: 160)
                .glassCard(cornerRadius: 20, tint: .purple)
            }

            // Edit options
            ForEach(["Remove Background", "Replace Object", "Upscale (4×)", "Enhance Quality", "Social Media Format"], id: \.self) { option in
                Button(option) { }
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .glassCard(cornerRadius: 14)
            }
        }
    }

    private var galleryTab: some View {
        Group {
            if generatedImages.isEmpty {
                VStack(spacing: 14) {
                    Image(systemName: "photo.stack")
                        .font(.system(size: 52))
                        .foregroundStyle(.white.opacity(0.3))
                    Text("No images generated yet")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.6))
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 60)
            } else {
                LazyVGrid(columns: [.init(.flexible(), spacing: 10), .init(.flexible(), spacing: 10)], spacing: 10) {
                    ForEach(generatedImages) { img in
                        GeneratedImageCard(image: img)
                    }
                }
            }
        }
    }

    private func generateImage() {
        guard !prompt.isEmpty else { return }
        promptFocused = false
        isGenerating = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            let img = GeneratedImage(prompt: prompt, style: styles[selectedStyle], size: sizes[selectedSize])
            generatedImages.insert(img, at: 0)
            isGenerating = false
        }
    }
}

private struct GeneratedImage: Identifiable {
    let id = UUID()
    let prompt: String
    let style: String
    let size: String
    let createdAt = Date()
}

private struct GeneratedImageCard: View {
    let image: GeneratedImage

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [.purple.opacity(0.3), .blue.opacity(0.2)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 130)
                .overlay(
                    Image(systemName: "photo")
                        .font(.largeTitle)
                        .foregroundStyle(.white.opacity(0.3))
                )

            Text(image.prompt)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))
                .lineLimit(2)

            HStack {
                Text(image.style)
                    .font(.caption2)
                    .foregroundStyle(.purple.opacity(0.8))
                Spacer()
                Button {
                    // Share
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
        }
        .padding(10)
        .glassCard(cornerRadius: 16)
    }
}
