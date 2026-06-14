import SwiftUI
import WebKit

struct WebsiteBuilderView: View {
    @Environment(AppState.self) private var appState
    @State private var prompt = ""
    @State private var isGenerating = false
    @State private var generatedHTML = ""
    @State private var previewDevice = 0 // 0=mobile, 1=tablet, 2=desktop
    @State private var selectedSection = ""
    @FocusState private var promptFocused: Bool

    var body: some View {
        ZStack {
            AnimatedBackground()

            VStack(spacing: 0) {
                HStack {
                    Text("Website Builder")
                        .font(.title.weight(.bold))
                        .foregroundStyle(.white)
                    Spacer()
                    if !generatedHTML.isEmpty {
                        Button {
                            // Export
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                                .font(.body.weight(.medium))
                                .foregroundStyle(.white)
                                .frame(width: 36, height: 36)
                                .glassCircle(interactive: true)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                if generatedHTML.isEmpty {
                    buildForm
                } else {
                    previewPanel
                }
            }
        }
        .ignoresSafeArea()
        .toolbarVisibility(.hidden, for: .navigationBar)
    }

    private var buildForm: some View {
        ScrollView {
            VStack(spacing: 14) {
                GlassCard(cornerRadius: 18) {
                    VStack(alignment: .leading, spacing: 10) {
                        Label("Describe your website", systemImage: "globe")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.5))
                        ZStack(alignment: .topLeading) {
                            if prompt.isEmpty {
                                Text("e.g. A portfolio website for a photographer with dark theme and gallery…")
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

                // Template suggestions
                GlassCard(cornerRadius: 18) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Quick Start").font(.caption.weight(.semibold)).foregroundStyle(.white.opacity(0.5))
                        let templates = ["Portfolio", "Landing Page", "Blog", "E-commerce", "SaaS", "Restaurant"]
                        LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 3), spacing: 8) {
                            ForEach(templates, id: \.self) { t in
                                Button(t) { prompt = "Build a \(t.lowercased()) website" }
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(.white.opacity(0.75))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 9)
                                    .glassCard(cornerRadius: 10)
                            }
                        }
                    }
                }

                Button {
                    promptFocused = false
                    buildWebsite()
                } label: {
                    HStack(spacing: 10) {
                        if isGenerating {
                            ProgressView().tint(.white)
                            Text("Building website…")
                        } else {
                            Image(systemName: "globe.badge.chevron.backward")
                            Text("Build Website")
                        }
                    }
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .glassCard(cornerRadius: 18, tint: .cyan)
                }
                .disabled(prompt.isEmpty || isGenerating)

                Color.clear.frame(height: 30)
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)
        }
    }

    private var previewPanel: some View {
        VStack(spacing: 12) {
            // Device switcher
            if #available(iOS 26, *) {
                GlassEffectContainer(spacing: 4) {
                    HStack(spacing: 4) {
                        ForEach(
                            [(0, "iphone", "Mobile"), (1, "ipad", "Tablet"), (2, "macbook", "Desktop")],
                            id: \.0
                        ) { tag, icon, label in
                            Button {
                                withAnimation(.smooth) { previewDevice = tag }
                            } label: {
                                Label(label, systemImage: icon)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(previewDevice == tag ? .white : .white.opacity(0.5))
                                    .padding(.horizontal, 14).padding(.vertical, 9)
                            }
                            .glassEffect(previewDevice == tag ? .regular.tint(.cyan.opacity(0.4)).interactive() : .regular.interactive(), in: .capsule)
                        }
                    }
                    .padding(4)
                }
                .padding(.horizontal, 20)
            } else {
                Picker("Device", selection: $previewDevice) {
                    Text("Mobile").tag(0)
                    Text("Tablet").tag(1)
                    Text("Desktop").tag(2)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 20)
            }

            // Preview
            WebPreview(html: generatedHTML, device: previewDevice)
                .frame(maxWidth: previewWidth, maxHeight: 420)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.4), radius: 20, y: 10)
                .padding(.horizontal, 20)

            // Modification suggestions
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(["Change colors", "Add section", "Update fonts", "Add contact form", "Dark mode"], id: \.self) { mod in
                        Button(mod) {
                            // Apply modification
                        }
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.white.opacity(0.75))
                        .padding(.horizontal, 12).padding(.vertical, 7)
                        .glassCapsule()
                    }
                }
                .padding(.horizontal, 20)
            }

            Button("Reset & Rebuild") {
                withAnimation { generatedHTML = "" }
            }
            .font(.subheadline)
            .foregroundStyle(.white.opacity(0.5))
            .padding(.bottom, 20)
        }
    }

    private var previewWidth: CGFloat {
        switch previewDevice {
        case 0: return 320
        case 1: return 480
        default: return .infinity
        }
    }

    private func buildWebsite() {
        isGenerating = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            generatedHTML = """
            <!DOCTYPE html><html><head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width,initial-scale=1">
            <title>Generated Site</title>
            <style>
            * { margin:0; padding:0; box-sizing:border-box; }
            body { font-family: -apple-system,sans-serif; background:#0a0a1a; color:#fff; }
            .hero { min-height:100vh; display:flex; align-items:center; justify-content:center;
                    background:linear-gradient(135deg,#001aff22,#8000ff22);
                    text-align:center; padding:2rem; }
            h1 { font-size:3rem; font-weight:100; letter-spacing:0.5rem; margin-bottom:1rem; }
            p  { opacity:0.7; font-size:1.1rem; }
            </style></head>
            <body><div class="hero"><div>
            <h1>De AI Built This</h1>
            <p>\(prompt.prefix(80))</p>
            </div></div></body></html>
            """
            isGenerating = false
        }
    }
}

struct WebPreview: UIViewRepresentable {
    let html: String
    let device: Int

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = true
        webView.backgroundColor = UIColor(Color(red: 0.04, green: 0.04, blue: 0.1))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.loadHTMLString(html, baseURL: nil)
    }
}
