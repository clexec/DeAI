import SwiftUI

struct SandboxView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedLanguage = 0
    @State private var code = ""
    @State private var output = ""
    @State private var isRunning = false
    @State private var selectedPanel = 0
    @FocusState private var codeFocused: Bool

    let languages = ["Python", "JavaScript", "HTML/CSS", "SQL", "Swift"]
    let starterCode: [String] = [
        "# Python\nprint('Hello from De AI Sandbox!')\n\nfor i in range(5):\n    print(f'  {i}: {i**2}')",
        "// JavaScript\nconsole.log('Hello from De AI!');\n\nconst nums = [1, 2, 3, 4, 5];\nconst squares = nums.map(n => n * n);\nconsole.log('Squares:', squares);",
        "<!-- HTML -->\n<!DOCTYPE html>\n<html>\n<body style='font-family:sans-serif;padding:20px;background:#0a0a1a;color:white'>\n  <h1>De AI HTML Preview</h1>\n  <p>Edit this code and run it!</p>\n</body>\n</html>",
        "-- SQL\nCREATE TABLE users (id INT, name TEXT, email TEXT);\nINSERT INTO users VALUES (1, 'Alice', 'alice@example.com');\nINSERT INTO users VALUES (2, 'Bob', 'bob@example.com');\nSELECT * FROM users WHERE id > 0;",
        "// Swift\nimport Foundation\n\nlet greeting = \"Hello from Swift!\"\nprint(greeting)\n\nlet numbers = 1...10\nlet evens = numbers.filter { $0 % 2 == 0 }\nprint(\"Evens:\", evens)",
    ]

    var body: some View {
        ZStack {
            AnimatedBackground()

            VStack(spacing: 0) {
                // Header
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Sandbox")
                            .font(.title.weight(.bold))
                            .foregroundStyle(.white)
                        Text("Execute code in real time")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.4))
                    }
                    Spacer()
                    Button {
                        runCode()
                    } label: {
                        HStack(spacing: 7) {
                            if isRunning {
                                ProgressView().tint(.white).scaleEffect(0.85)
                                Text("Running…")
                            } else {
                                Image(systemName: "play.fill")
                                Text("Run")
                            }
                        }
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16).padding(.vertical, 9)
                        .glassCapsule(tint: .green, interactive: true)
                    }
                    .disabled(isRunning)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                // Language selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(languages.indices, id: \.self) { i in
                            Button(languages[i]) {
                                withAnimation(.smooth) {
                                    selectedLanguage = i
                                    code = starterCode[i]
                                    output = ""
                                }
                            }
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(selectedLanguage == i ? .white : .white.opacity(0.5))
                            .padding(.horizontal, 14).padding(.vertical, 8)
                            .glassCapsule(tint: selectedLanguage == i ? .green : nil)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.top, 10)

                // Panel switcher
                HStack(spacing: 4) {
                    ForEach(["Editor", "Output", "Files", "Logs"].indices, id: \.self) { i in
                        Button(["Editor", "Output", "Files", "Logs"][i]) {
                            withAnimation(.smooth) { selectedPanel = i }
                        }
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(selectedPanel == i ? .white : .white.opacity(0.45))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(selectedPanel == i ? Color.white.opacity(0.1) : Color.clear)
                        .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 6)
                .glassCard(cornerRadius: 0)

                Divider().overlay(.white.opacity(0.08))

                // Content panels
                switch selectedPanel {
                case 0: editorPanel
                case 1: outputPanel
                case 2: filesPanel
                default: logsPanel
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            code = starterCode[0]
        }
    }

    // MARK: - Editor

    private var editorPanel: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Line numbers + code editor
                HStack(alignment: .top, spacing: 0) {
                    // Line numbers
                    VStack(alignment: .trailing, spacing: 0) {
                        ForEach(Array(code.components(separatedBy: "\n").enumerated()), id: \.offset) { i, _ in
                            Text("\(i + 1)")
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundStyle(.white.opacity(0.25))
                                .frame(width: 32, alignment: .trailing)
                                .padding(.vertical, 1)
                        }
                    }
                    .padding(.top, 12)

                    // Code editor
                    TextEditor(text: $code)
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundStyle(.white)
                        .scrollContentBackground(.hidden)
                        .frame(minHeight: 400)
                        .padding(.horizontal, 8)
                        .focused($codeFocused)
                }

                // AI suggestions bar
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        Label("AI Assist", systemImage: "sparkles")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.4))
                        ForEach(["Fix errors", "Optimize", "Add comments", "Write tests"], id: \.self) { action in
                            Button(action) { }
                                .font(.caption.weight(.medium))
                                .foregroundStyle(.white.opacity(0.65))
                                .padding(.horizontal, 10).padding(.vertical, 5)
                                .glassCapsule()
                        }
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 10)
                .background(.white.opacity(0.03))
            }
            .padding(.bottom, 30)
        }
    }

    // MARK: - Output

    private var outputPanel: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if output.isEmpty {
                    HStack(spacing: 8) {
                        Image(systemName: "play.circle")
                            .foregroundStyle(.white.opacity(0.3))
                        Text("Run your code to see output here")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.3))
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 40)
                } else {
                    HStack(spacing: 8) {
                        Image(systemName: "terminal.fill")
                            .foregroundStyle(.green.opacity(0.7))
                        Text("Output")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.4))
                        Spacer()
                        Button("Clear") { output = "" }
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.3))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)

                    Text(output)
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundStyle(.green.opacity(0.9))
                        .padding(.horizontal, 16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Color.clear.frame(height: 40)
            }
        }
    }

    // MARK: - Files

    private var filesPanel: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Sandbox Files").font(.subheadline.weight(.semibold)).foregroundStyle(.white.opacity(0.6))
                Spacer()
                Button { } label: {
                    Image(systemName: "plus")
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 12)

            ForEach(["main.\(languageExtension)", "utils.\(languageExtension)", "README.md"], id: \.self) { file in
                HStack(spacing: 10) {
                    Image(systemName: "doc.text")
                        .foregroundStyle(.white.opacity(0.5))
                    Text(file)
                        .font(.system(.subheadline, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.8))
                    Spacer()
                }
                .padding(12)
                .glassCard(cornerRadius: 12)
                .padding(.horizontal, 20)
            }

            Spacer()
        }
    }

    // MARK: - Logs

    private var logsPanel: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 4) {
                ForEach([
                    ("[info] Sandbox initialized", Color.white.opacity(0.4)),
                    ("[info] Language: \(languages[selectedLanguage])", Color.white.opacity(0.4)),
                    (output.isEmpty ? "[idle] Waiting for execution" : "[info] Last run completed", Color.green.opacity(0.7))
                ], id: \.0) { msg, color in
                    Text(msg)
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundStyle(color)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
        }
    }

    private var languageExtension: String {
        ["py", "js", "html", "sql", "swift"][selectedLanguage]
    }

    private func runCode() {
        codeFocused = false
        isRunning = true
        output = ""
        selectedPanel = 1

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            let lang = languages[selectedLanguage]
            output = """
            [\(lang) Runtime] Executing…

            Hello from De AI Sandbox!
              0: 0
              1: 1
              2: 4
              3: 9
              4: 16

            ─────────────────
            Execution completed in 0.032s
            Exit code: 0
            """
            isRunning = false
        }
    }
}
