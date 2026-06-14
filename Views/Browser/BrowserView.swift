import SwiftUI
import WebKit

struct BrowserView: View {
    @Environment(AppState.self) private var appState
    @State private var urlText = "https://www.apple.com"
    @State private var committedURL: URL? = URL(string: "https://www.apple.com")
    @State private var isLoading = false
    @State private var pageTitle = ""
    @State private var tabs: [BrowserTab] = [BrowserTab(url: URL(string: "https://www.apple.com")!, title: "Apple")]
    @State private var selectedTabID: UUID = UUID()
    @State private var showAIPanel = false
    @State private var aiQuestion = ""
    @State private var aiAnswer = ""
    @State private var showTabList = false
    @FocusState private var urlFocused: Bool

    var body: some View {
        ZStack {
            AnimatedBackground()

            VStack(spacing: 0) {
                browserNavBar
                tabBar
                    .padding(.horizontal, 20)
                    .padding(.top, 6)

                // Main web content
                ZStack(alignment: .bottom) {
                    if let url = committedURL {
                        LiveWebView(
                            url: url,
                            isLoading: $isLoading,
                            pageTitle: $pageTitle
                        )
                        .ignoresSafeArea(edges: .bottom)
                    } else {
                        newTabPage
                    }

                    // AI Assistant panel
                    if showAIPanel {
                        aiAssistantPanel
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showTabList) { tabListSheet }
    }

    // MARK: - Nav Bar

    private var browserNavBar: some View {
        HStack(spacing: 10) {
            // Back button
            Button { } label: {
                Image(systemName: "chevron.left")
                    .font(.body.weight(.semibold))
                    .frame(width: 36, height: 36)
                    .foregroundStyle(.white.opacity(0.7))
                    .glassCircle(interactive: true)
            }

            // URL bar
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView().tint(.white.opacity(0.7)).scaleEffect(0.75)
                } else {
                    Image(systemName: "lock.fill")
                        .font(.caption2)
                        .foregroundStyle(.green.opacity(0.8))
                }
                TextField("", text: $urlText, prompt: Text("Search or enter URL").foregroundStyle(.white.opacity(0.4)))
                    .foregroundStyle(.white)
                    .font(.system(.subheadline, design: .monospaced))
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .keyboardType(.URL)
                    .focused($urlFocused)
                    .onSubmit { navigate() }
                if !urlText.isEmpty && urlFocused {
                    Button { urlText = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.white.opacity(0.4))
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 9)
            .glassCard(cornerRadius: 14)

            // AI button
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                    showAIPanel.toggle()
                }
            } label: {
                Image(systemName: showAIPanel ? "xmark" : "sparkles")
                    .font(.body.weight(.semibold))
                    .frame(width: 36, height: 36)
                    .foregroundStyle(.white)
                    .glassCircle(interactive: true)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
    }

    // MARK: - Tab Bar

    private var tabBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(tabs) { tab in
                    BrowserTabChip(
                        tab: tab,
                        isSelected: tab.id == selectedTabID,
                        onSelect: { selectedTabID = tab.id; committedURL = tab.url },
                        onClose: { closeTab(tab.id) }
                    )
                }
                Button {
                    addNewTab()
                } label: {
                    Image(systemName: "plus")
                        .font(.body.weight(.semibold))
                        .frame(width: 36, height: 36)
                        .foregroundStyle(.white.opacity(0.6))
                        .glassCircle(interactive: true)
                }
            }
        }
    }

    // MARK: - New Tab Page

    private var newTabPage: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text("New Tab")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.top, 40)

                VStack(spacing: 8) {
                    Text("Bookmarks").font(.caption.weight(.semibold)).foregroundStyle(.white.opacity(0.5))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 4), spacing: 12) {
                        ForEach(["apple.com", "github.com", "openai.com", "anthropic.com"], id: \.self) { site in
                            Button {
                                urlText = "https://\(site)"
                                navigate()
                            } label: {
                                VStack(spacing: 6) {
                                    Circle()
                                        .fill(.white.opacity(0.1))
                                        .frame(width: 48, height: 48)
                                        .overlay(
                                            Text(String(site.prefix(1)).uppercased())
                                                .font(.title3.weight(.semibold))
                                                .foregroundStyle(.white)
                                        )
                                    Text(site.replacingOccurrences(of: ".com", with: ""))
                                        .font(.caption2)
                                        .foregroundStyle(.white.opacity(0.6))
                                }
                            }
                        }
                    }
                }
                .padding(16)
                .glassCard(cornerRadius: 18)
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - AI Panel

    private var aiAssistantPanel: some View {
        VStack(spacing: 12) {
            HStack {
                Label("AI Assistant", systemImage: "sparkles")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                Spacer()
                if !pageTitle.isEmpty {
                    Text(pageTitle)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.4))
                        .lineLimit(1)
                }
            }

            if !aiAnswer.isEmpty {
                ScrollView {
                    Text(aiAnswer)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.9))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxHeight: 120)
            }

            // Quick actions
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(["Summarize page", "Key points", "Translate", "Ask a question"], id: \.self) { action in
                        Button(action) { aiAnswer = "AI is analyzing \"\(pageTitle.isEmpty ? "this page" : pageTitle)\"…" }
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.white.opacity(0.75))
                            .padding(.horizontal, 12).padding(.vertical, 7)
                            .glassCapsule()
                    }
                }
            }

            // Custom question
            HStack(spacing: 10) {
                TextField("", text: $aiQuestion, prompt: Text("Ask about this page…").foregroundStyle(.white.opacity(0.4)))
                    .foregroundStyle(.white)
                    .font(.subheadline)
                Button {
                    if !aiQuestion.isEmpty {
                        aiAnswer = "Analyzing page for: \"\(aiQuestion)\"…"
                        aiQuestion = ""
                    }
                } label: {
                    Image(systemName: "arrow.up")
                        .font(.body.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(width: 34, height: 34)
                        .glassCircle(interactive: true)
                }
            }
        }
        .padding(16)
        .glassCard(cornerRadius: 24, tint: .blue)
        .padding(.horizontal, 16)
        .padding(.bottom, 20)
        .shadow(color: .black.opacity(0.3), radius: 20, y: -5)
    }

    private var tabListSheet: some View {
        Text("Tab manager — \(tabs.count) tabs")
    }

    // MARK: - Helpers

    private func navigate() {
        var raw = urlText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !raw.hasPrefix("http") { raw = "https://\(raw)" }
        if let url = URL(string: raw) {
            committedURL = url
            urlFocused = false
        }
    }

    private func addNewTab() {
        let tab = BrowserTab(url: URL(string: "about:blank")!, title: "New Tab")
        tabs.append(tab)
        selectedTabID = tab.id
        committedURL = nil
    }

    private func closeTab(_ id: UUID) {
        tabs.removeAll { $0.id == id }
        if tabs.isEmpty { addNewTab() }
    }
}

struct BrowserTab: Identifiable {
    let id = UUID()
    var url: URL
    var title: String
}

private struct BrowserTabChip: View {
    let tab: BrowserTab
    let isSelected: Bool
    let onSelect: () -> Void
    let onClose: () -> Void

    var body: some View {
        HStack(spacing: 6) {
            Button(action: onSelect) {
                Text(tab.title)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(isSelected ? .white : .white.opacity(0.5))
                    .lineLimit(1)
                    .frame(maxWidth: 90)
            }
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .glassCapsule(tint: isSelected ? .blue : nil)
    }
}

struct LiveWebView: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool
    @Binding var pageTitle: String

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> WKWebView {
        let wv = WKWebView()
        wv.navigationDelegate = context.coordinator
        wv.load(URLRequest(url: url))
        return wv
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if uiView.url != url {
            uiView.load(URLRequest(url: url))
        }
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        let parent: LiveWebView
        init(_ parent: LiveWebView) { self.parent = parent }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation _: WKNavigation!) {
            parent.isLoading = true
        }
        func webView(_ webView: WKWebView, didFinish _: WKNavigation!) {
            parent.isLoading = false
            parent.pageTitle = webView.title ?? ""
        }
        func webView(_ webView: WKWebView, didFail _: WKNavigation!, withError _: Error) {
            parent.isLoading = false
        }
    }
}
