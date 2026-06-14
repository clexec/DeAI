import SwiftUI

struct MemoryView: View {
    @Environment(AppState.self) private var appState
    @State private var isAddingMemory = false
    @State private var newMemoryText = ""
    @State private var isPaused = false
    @State private var editingItem: MemoryItem?
    @State private var editText = ""

    var body: some View {
        ZStack {
            AnimatedBackground()

            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Memory")
                            .font(.title.weight(.bold))
                            .foregroundStyle(.white)
                        Text("\(appState.memories.filter { $0.isEnabled }.count) active")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.45))
                    }
                    Spacer()
                    HStack(spacing: 10) {
                        Toggle("", isOn: $isPaused)
                            .labelsHidden()
                            .tint(.orange)

                        Button {
                            isAddingMemory = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.body.weight(.semibold))
                                .frame(width: 36, height: 36)
                                .foregroundStyle(.white)
                                .glassCircle(interactive: true)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                if isPaused {
                    pausedBanner
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                }

                ScrollView {
                    LazyVStack(spacing: 10) {
                        if appState.memories.isEmpty {
                            emptyState
                        } else {
                            ForEach(appState.memories) { item in
                                MemoryItemRow(
                                    item: item,
                                    onToggle: { appState.toggleMemory(item.id) },
                                    onEdit: { editingItem = item; editText = item.content },
                                    onDelete: { appState.deleteMemory(item.id) }
                                )
                            }
                        }
                        Color.clear.frame(height: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                }
            }
        }
        .ignoresSafeArea()
        .toolbarVisibility(.hidden, for: .navigationBar)
        .sheet(isPresented: $isAddingMemory) { addMemorySheet }
        .sheet(item: $editingItem) { item in editMemorySheet(item: item) }
    }

    private var pausedBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "pause.circle.fill")
                .foregroundStyle(.orange)
            Text("Memory is paused for this session")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))
            Spacer()
        }
        .padding(12)
        .glassCard(cornerRadius: 14, tint: .orange)
    }

    private var emptyState: some View {
        VStack(spacing: 14) {
            Image(systemName: "brain")
                .font(.system(size: 52))
                .foregroundStyle(.white.opacity(0.3))
            Text("No memories yet")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white.opacity(0.6))
            Text("De AI will remember things\nyou want it to keep in mind")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.4))
                .multilineTextAlignment(.center)
            Button("Add a memory") { isAddingMemory = true }
                .buttonStyle(.deaiGlass)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }

    private var addMemorySheet: some View {
        ZStack {
            AnimatedBackground()
            VStack(spacing: 20) {
                Text("Add Memory")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.top, 28)
                TextEditor(text: $newMemoryText)
                    .foregroundStyle(.white)
                    .scrollContentBackground(.hidden)
                    .padding(14)
                    .glassCard(cornerRadius: 16)
                    .frame(height: 140)
                    .padding(.horizontal, 20)
                Spacer()
                Button("Save Memory") {
                    appState.addMemory(newMemoryText)
                    newMemoryText = ""
                    isAddingMemory = false
                }
                .buttonStyle(.deaiGlassProminent())
                .disabled(newMemoryText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .padding(.horizontal, 20)
                .padding(.bottom, 34)
            }
        }
        .ignoresSafeArea()
    }

    private func editMemorySheet(item: MemoryItem) -> some View {
        ZStack {
            AnimatedBackground()
            VStack(spacing: 20) {
                Text("Edit Memory")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.top, 28)
                TextEditor(text: $editText)
                    .foregroundStyle(.white)
                    .scrollContentBackground(.hidden)
                    .padding(14)
                    .glassCard(cornerRadius: 16)
                    .frame(height: 140)
                    .padding(.horizontal, 20)
                Spacer()
                Button("Save Changes") {
                    if let idx = appState.memories.firstIndex(where: { $0.id == item.id }) {
                        appState.memories[idx].content = editText
                    }
                    editingItem = nil
                }
                .buttonStyle(.deaiGlassProminent())
                .padding(.horizontal, 20)
                .padding(.bottom, 34)
            }
        }
        .ignoresSafeArea()
    }
}

private struct MemoryItemRow: View {
    let item: MemoryItem
    let onToggle: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Toggle("", isOn: .init(get: { item.isEnabled }, set: { _ in onToggle() }))
                .labelsHidden()
                .tint(.blue)
                .padding(.top, 2)

            Text(item.preview)
                .font(.subheadline)
                .foregroundStyle(item.isEnabled ? .white : .white.opacity(0.4))
                .frame(maxWidth: .infinity, alignment: .leading)

            Menu {
                Button("Edit", systemImage: "pencil") { onEdit() }
                Button("Delete", systemImage: "trash", role: .destructive) { onDelete() }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.4))
                    .frame(width: 28, height: 28)
                    .glassCircle(interactive: true)
            }
        }
        .padding(14)
        .glassCard(cornerRadius: 16)
    }
}
