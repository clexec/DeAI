import SwiftUI

struct AgentTaskPanel: View {
    let tasks: [AgentTask]

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("Working on it", systemImage: "bolt.fill")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.orange)
                .padding(.bottom, 2)

            ForEach(tasks) { task in
                AgentTaskRow(task: task)
            }
        }
        .padding(14)
        .glassCard(cornerRadius: 16, tint: .orange)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct AgentTaskRow: View {
    let task: AgentTask
    @State private var isExpanded = false
    @State private var rotationAngle: Double = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Main row
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 10) {
                    // Status indicator
                    ZStack {
                        if task.status == .running {
                            Circle()
                                .stroke(task.status.statusColor.opacity(0.3), lineWidth: 2)
                                .frame(width: 20, height: 20)

                            Circle()
                                .trim(from: 0, to: 0.7)
                                .stroke(task.status.statusColor, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                                .frame(width: 20, height: 20)
                                .rotationEffect(.degrees(rotationAngle))
                                .onAppear {
                                    withAnimation(.linear(duration: 0.9).repeatForever(autoreverses: false)) {
                                        rotationAngle = 360
                                    }
                                }
                        } else {
                            Image(systemName: task.status.iconName)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(task.status.statusColor)
                                .frame(width: 20, height: 20)
                        }
                    }

                    VStack(alignment: .leading, spacing: 1) {
                        Text(task.title)
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.white)
                        Text(task.description)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.5))
                    }

                    Spacer()

                    if !task.logs.isEmpty {
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.4))
                    }
                }
                .padding(.vertical, 6)
            }

            // Expanded logs
            if isExpanded && !task.logs.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Divider().overlay(.white.opacity(0.1))
                    ForEach(task.logs) { log in
                        HStack(alignment: .top, spacing: 6) {
                            Text(log.level.prefix)
                                .font(.system(size: 10, weight: .bold, design: .monospaced))
                                .foregroundStyle(log.level.color)
                                .frame(width: 12)
                            Text(log.message)
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundStyle(.white.opacity(0.65))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }

                    // Generated outputs
                    if !task.generatedOutputs.isEmpty {
                        Divider().overlay(.white.opacity(0.1))
                        ForEach(task.generatedOutputs, id: \.self) { output in
                            Label(output, systemImage: "doc.text")
                                .font(.caption)
                                .foregroundStyle(.green.opacity(0.8))
                        }
                    }
                }
                .padding(.leading, 30)
                .padding(.vertical, 6)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
}
