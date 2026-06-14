import SwiftUI

struct ProjectsView: View {
    @Environment(AppState.self) private var appState
    @State private var showNewProject = false
    @State private var searchText = ""

    private var filtered: [Project] {
        guard !searchText.isEmpty else { return appState.projects }
        return appState.projects.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        ZStack {
            AnimatedBackground()

            VStack(spacing: 0) {
                navBar

                ScrollView {
                    LazyVStack(spacing: 14) {
                        if filtered.isEmpty {
                            emptyState
                        } else {
                            ForEach(filtered) { project in
                                NavigationLink(value: AppPath.projectDetail(project.id)) {
                                    ProjectCard(project: project)
                                }
                                .buttonStyle(.plain)
                            }
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
        .sheet(isPresented: $showNewProject) {
            NewProjectSheet()
        }
    }

    private var navBar: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Projects")
                    .font(.title.weight(.bold))
                    .foregroundStyle(.white)
                Spacer()
                GlassButton(icon: "plus", shape: .circle) {
                    showNewProject = true
                }
                .foregroundStyle(.white)
            }

            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass").foregroundStyle(.white.opacity(0.5))
                TextField("", text: $searchText, prompt: Text("Search projects…").foregroundStyle(.white.opacity(0.4)))
                    .foregroundStyle(.white)
                    .autocorrectionDisabled()
            }
            .padding(.horizontal, 14).padding(.vertical, 11)
            .glassCard(cornerRadius: 14)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "folder.badge.plus")
                .font(.system(size: 52))
                .foregroundStyle(.white.opacity(0.3))
            VStack(spacing: 6) {
                Text("No Projects Yet")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.7))
                Text("Create a project to organize\nconversations, files and AI settings")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.4))
                    .multilineTextAlignment(.center)
            }
            Button("Create Project") { showNewProject = true }
                .buttonStyle(.glassProminent)
                .tint(.blue)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }
}

private struct ProjectCard: View {
    let project: Project

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(project.displayColor.opacity(0.25))
                    .frame(width: 52, height: 52)
                Image(systemName: project.iconName)
                    .font(.title2.weight(.medium))
                    .foregroundStyle(project.displayColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(project.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                if !project.description.isEmpty {
                    Text(project.description)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.55))
                        .lineLimit(1)
                }
                HStack(spacing: 10) {
                    Label("\(project.conversationIDs.count)", systemImage: "bubble.left")
                    Label("\(project.files.count)", systemImage: "doc")
                }
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.4))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.3))
        }
        .padding(16)
        .glassCard(cornerRadius: 20)
    }
}

private struct NewProjectSheet: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var description = ""
    @State private var selectedIcon = "folder.fill"
    @State private var selectedColor = Color.blue

    var body: some View {
        ZStack {
            AnimatedBackground()
            VStack(spacing: 20) {
                Text("New Project")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.top, 24)

                VStack(spacing: 12) {
                    TextField("", text: $name, prompt: Text("Project name").foregroundStyle(.white.opacity(0.4)))
                        .foregroundStyle(.white)
                        .padding(14)
                        .glassCard(cornerRadius: 14)

                    TextField("", text: $description, prompt: Text("Description (optional)").foregroundStyle(.white.opacity(0.4)))
                        .foregroundStyle(.white)
                        .padding(14)
                        .glassCard(cornerRadius: 14)
                }
                .padding(.horizontal, 20)

                ColorPicker("Project color", selection: $selectedColor)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)

                Spacer()

                Button("Create Project") {
                    var project = Project(name: name, description: description)
                    project.colorHex = UIColor(selectedColor).toHexString()
                    appState.projects.append(project)
                    dismiss()
                }
                .buttonStyle(.glassProminent)
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .padding(.horizontal, 20)
                .padding(.bottom, 34)
            }
        }
        .ignoresSafeArea()
    }
}

private extension UIColor {
    func toHexString() -> String {
        var r: CGFloat = 0; var g: CGFloat = 0; var b: CGFloat = 0; var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "#%02X%02X%02X", Int(r*255), Int(g*255), Int(b*255))
    }
}
