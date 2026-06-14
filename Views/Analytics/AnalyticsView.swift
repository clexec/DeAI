import SwiftUI
import Charts

struct AnalyticsView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedPeriod = 0

    // Sample data for charts
    private var tokenData: [TokenDataPoint] {
        let calendar = Calendar.current
        return (0..<7).map { i in
            let date = calendar.date(byAdding: .day, value: -i, to: Date())!
            return TokenDataPoint(date: date, tokens: Int.random(in: 5000...50000))
        }.reversed()
    }

    private var modelUsageData: [ModelUsage] {
        [
            ModelUsage(model: "GPT-4o", percentage: 0.42, color: Color(red: 0.07, green: 0.73, blue: 0.54)),
            ModelUsage(model: "Claude Sonnet", percentage: 0.28, color: .orange),
            ModelUsage(model: "Gemini Pro", percentage: 0.18, color: .blue),
            ModelUsage(model: "Other", percentage: 0.12, color: .gray),
        ]
    }

    var body: some View {
        ZStack {
            AnimatedBackground()

            ScrollView {
                VStack(spacing: 16) {
                    // Header
                    HStack {
                        Text("Analytics")
                            .font(.title.weight(.bold))
                            .foregroundStyle(.white)
                        Spacer()
                        Picker("Period", selection: $selectedPeriod) {
                            Text("7d").tag(0)
                            Text("30d").tag(1)
                            Text("All").tag(2)
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 120)
                    }

                    // Summary cards
                    LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], spacing: 12) {
                        MetricCard(
                            title: "Total Tokens",
                            value: "\(appState.totalTokensUsed.formatted())",
                            icon: "text.word.spacing",
                            color: .blue
                        )
                        MetricCard(
                            title: "Est. Cost",
                            value: "$\(String(format: "%.2f", appState.totalCost))",
                            icon: "dollarsign.circle.fill",
                            color: .green
                        )
                        MetricCard(
                            title: "Conversations",
                            value: "\(appState.conversations.count)",
                            icon: "bubble.left.and.bubble.right.fill",
                            color: .purple
                        )
                        MetricCard(
                            title: "Projects",
                            value: "\(appState.projects.count)",
                            icon: "folder.fill",
                            color: .orange
                        )
                    }

                    // Token usage chart
                    GlassCard(cornerRadius: 20) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Token Usage")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.white)

                            Chart(tokenData, id: \.date) { point in
                                AreaMark(
                                    x: .value("Date", point.date),
                                    y: .value("Tokens", point.tokens)
                                )
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.blue.opacity(0.6), .blue.opacity(0.1)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                LineMark(
                                    x: .value("Date", point.date),
                                    y: .value("Tokens", point.tokens)
                                )
                                .foregroundStyle(.blue)
                                .lineStyle(StrokeStyle(lineWidth: 2))
                            }
                            .chartXAxis {
                                AxisMarks(values: .stride(by: .day)) {
                                    AxisValueLabel(format: .dateTime.weekday(.abbreviated))
                                        .foregroundStyle(Color.white.opacity(0.5))
                                }
                            }
                            .chartYAxis {
                                AxisMarks { val in
                                    AxisValueLabel()
                                        .foregroundStyle(Color.white.opacity(0.5))
                                }
                            }
                            .frame(height: 160)
                        }
                    }

                    // Model usage donut
                    GlassCard(cornerRadius: 20) {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Model Usage")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.white)

                            HStack(spacing: 20) {
                                Chart(modelUsageData, id: \.model) { usage in
                                    SectorMark(
                                        angle: .value("Pct", usage.percentage),
                                        innerRadius: .ratio(0.6),
                                        angularInset: 2
                                    )
                                    .foregroundStyle(usage.color)
                                    .cornerRadius(4)
                                }
                                .frame(width: 120, height: 120)

                                VStack(alignment: .leading, spacing: 8) {
                                    ForEach(modelUsageData, id: \.model) { usage in
                                        HStack(spacing: 8) {
                                            Circle().fill(usage.color).frame(width: 8, height: 8)
                                            Text(usage.model)
                                                .font(.caption)
                                                .foregroundStyle(.white.opacity(0.8))
                                            Spacer()
                                            Text("\(Int(usage.percentage * 100))%")
                                                .font(.caption.weight(.semibold))
                                                .foregroundStyle(.white)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Color.clear.frame(height: 30)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
            }
        }
        .ignoresSafeArea()
        .toolbar(.hidden, for: .navigationBar)
    }
}

private struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(value)
                .font(.title2.weight(.bold))
                .foregroundStyle(.white)
            Text(title)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .glassCard(cornerRadius: 18, tint: color)
    }
}

private struct TokenDataPoint {
    let date: Date
    let tokens: Int
}

private struct ModelUsage {
    let model: String
    let percentage: Double
    let color: Color
}
