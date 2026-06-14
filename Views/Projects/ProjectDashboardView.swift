import SwiftUI

struct ProjectDashboardView: View {
    @Environment(AppState.self) private var appState
    let project: Project
    @State private var selectedTab = 0

    var projectConversations: [Conversation] {
        appState.conversations.filter { project.conversationIDs.contains($0.id) }
    }

    var body: some View {
        ZStack {
            AnimatedBackground()

            VStack(spacing: 0) {
                // Header
                projectHeader

                // Tab selector
                if #available(iOS 26, *) {
                    GlassEffectContainer(spacing: 4) {
                        HStack(spacing: 4) {
                            ForEach(["Chats", "Files", "Memory", "Settings"].indices, id: \.self) { i in
                                Button(["Chats", "Files", "Memory", "Settings"][i]) {
                                    withAnimation(.smooth) { selectedTab = i }
                                }
                                .font(.subheadline.weight(.medium))
                                .padding(.horizontal, 16).padding(.vertical, 8)
                                .foregroundStyle(selectedTab == i ? .white : .white.opacity(0.5))
                                .glassEffect(
                                    selectedTab == i
                                    ? .regular.tint(project.displayColor.opacity(0.4)).interactive()
                                    : .regular.interactive(),
                                    in: .capsule
                                )
                            }
                        }
                        .padding(4)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                } else {
                    Picker("", selection: $selectedTab) {
                        Text("Chats").tag(0)
                        Text("Files").tag(1)
                        Text("Memory").tag(2)
                        Text("Settings").tag(3)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 20).padding(.top, 12)
                }

                // Content
                ScrollView {
                    VStack(spacing: 14) {
                        switch selectedTab {
                        case 0: chatsTab
                        case 1: filesTab
                        case 2: memoryTab
                        default: settingsTab
                        }
                        Color.clear.frame(height: 30)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                }
            }
        }
        .ignoresSafeArea()
        .toolbarVisibility(.hidden, for: .navigationBar)
    }

    // MARK: - Header

    private var projectHeader: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(project.displayColor.opacity(0.25))
                    .frame(width: 60, height: 60)
                Image(systemName: project.iconName)
                    .font(.title.weight(.medium))
                    .foregroundStyle(project.displayColor)
            }
            .shadow(color: project.displayColor.opacity(0.4), radius: 12)

            VStack(alignment: .leading, spacing: 3) {
                Text(project.name)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
                if !project.description.isEmpty {
                    Text(project.description)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.6))
                }
                HStack(spacing: 12) {
                    Label("\(projectConversations.count) chats", systemImage: "bubble.left")
                    Label("\(project.files.count) files", systemImage: "doc")
                    Label("\(project.memories.count) memories", systemImage: "brain")
                }
                .font(.caption)
                .foregroundStyle(.white.opacity(0.45))
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }

    // MARK: - Tabs

    private var chatsTab: some View {
        VStack(spacing: 10) {
            Button {
                let conv = appState.createNewConversation(in: project.id)
                appState.navigationPath.append(.chat(conv.id))
            } label: {
                Label("New conversation", systemImage: "plus.bubble")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .glassCard(cornerRadius: 14, tint: project.displayColor)
            }

            ForEach(projectConversations) { conv in
                NavigationLink(value: AppPath.chat(conv.id)) {
                    HStack(spacing: 12) {
                        ProviderBadge(provider: conv.providerType, size: 34)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(conv.title).font(.subheadline.weight(.medium)).foregroundStyle(.white)
                            Text(conv.preview).font(.caption).foregroundStyle(.white.opacity(0.5)).lineLimit(1)
                        }
                        Spacer()
                        Image(systemName: "chevron.right").font(.caption).foregroundStyle(.white.opacity(0.3))
                    }
                    .padding(14)
                    .glassCard(cornerRadius: 14)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var filesTab: some View {
        Group {
            if project.files.isEmpty {
                Text("No files yet").foregroundStyle(.white.opacity(0.4)).padding(.top, 40)
            } else {
                ForEach(project.files) { file in
                    HStack(spacing: 12) {
                        Image(systemName: "doc.fill")
                            .foregroundStyle(project.displayColor)
                        Text(file.name).font(.subheadline).foregroundStyle(.white)
                        Spacer()
                        Text(ByteCountFormatter.string(fromByteCount: file.size, countStyle: .file))
                            .font(.caption).foregroundStyle(.white.opacity(0.4))
                    }
                    .padding(14)
                    .glassCard(cornerRadius: 14)
                }
            }
        }
    }

    private var memoryTab: some View {
        ForEach(project.memories) { mem in
            HStack(alignment: .top, spacing: 10) {
                Circle()
                    .fill(mem.isEnabled ? project.displayColor : Color.gray)
                    .frame(width: 8, height: 8)
                    .padding(.top, 6)
                Text(mem.content)
                    .font(.subheadline)
                    .foregroundStyle(mem.isEnabled ? .white : .white.opacity(0.4))
            }
            .padding(14)
            .glassCard(cornerRadius: 14)
        }
    }

    private var settingsTab: some View {
        VStack(spacing: 12) {
            GlassCard(cornerRadius: 18) {
                VStack(spacing: 16) {
                    HStack {
                        Text("AI Model")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.white)
                        Spacer()
                        Text(project.aiSettings.modelID)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    HStack {
                        Text("Reasoning")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.white)
                        Spacer()
                        Text(project.aiSettings.reasoningEnabled ? "Enabled" : "Disabled")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                    HStack {
                        Text("Temperature")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.white)
                        Spacer()
                        Text("\(project.aiSettings.temperature, format: .number.precision(.fractionLength(1)))")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
                .padding(4)
            }
        }
    }
}
