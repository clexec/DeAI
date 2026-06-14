import SwiftUI

struct AnimatedBackground: View {
    var parallaxOffset: CGFloat = 0

    var body: some View {
        TimelineView(.animation(minimumInterval: 1 / 60, paused: false)) { tl in
            let elapsed = tl.date.timeIntervalSinceReferenceDate
            Canvas { ctx, size in
                drawGradient(ctx: ctx, size: size, elapsed: elapsed)
                drawWaves(ctx: ctx, size: size, elapsed: elapsed)
                drawReflections(ctx: ctx, size: size, elapsed: elapsed)
            }
        }
        .offset(y: parallaxOffset * 0.28)
        .ignoresSafeArea()
    }

    // MARK: - Drawing

    private func drawGradient(ctx: GraphicsContext, size: CGSize, elapsed: Double) {
        let hueShift = sin(elapsed * 0.12) * 0.04
        let gradient = Gradient(stops: [
            .init(color: Color(hue: 0.60 + hueShift, saturation: 1, brightness: 0.95), location: 0.00),
            .init(color: Color(hue: 0.74 + hueShift, saturation: 1, brightness: 0.75), location: 0.38),
            .init(color: Color(hue: 0.76 + hueShift, saturation: 1, brightness: 0.25), location: 0.70),
            .init(color: Color(hue: 0.00, saturation: 0, brightness: 0.0),             location: 1.00),
        ])
        ctx.fill(
            Path(CGRect(origin: .zero, size: size)),
            with: .linearGradient(
                gradient,
                startPoint: .zero,
                endPoint: CGPoint(x: 0, y: size.height)
            )
        )
    }

    private func drawWaves(ctx: GraphicsContext, size: CGSize, elapsed: Double) {
        for i in 0..<5 {
            let fi = Double(i)
            let yBase = size.height * CGFloat(0.22 + fi * 0.12)
            let amplitude = CGFloat(35 + i * 8)
            let speed = 0.45 + fi * 0.07
            let phaseOffset = fi * .pi * 0.6

            var path = Path()
            path.move(to: CGPoint(x: 0, y: yBase))
            for xi in stride(from: CGFloat(0), through: size.width, by: 3) {
                let norm = Double(xi) / Double(size.width)
                let y = yBase + amplitude * CGFloat(
                    sin(norm * .pi * 2.5 + elapsed * speed + phaseOffset)
                    + 0.4 * sin(norm * .pi * 5.0 + elapsed * speed * 1.3 + phaseOffset)
                )
                path.addLine(to: CGPoint(x: xi, y: y))
            }
            path.addLine(to: CGPoint(x: size.width, y: size.height))
            path.addLine(to: CGPoint(x: 0, y: size.height))
            path.closeSubpath()

            let opacity = 0.025 + fi * 0.018
            ctx.fill(path, with: .color(Color.white.opacity(opacity)))
        }
    }

    private func drawReflections(ctx: GraphicsContext, size: CGSize, elapsed: Double) {
        // Subtle moving light streaks
        for i in 0..<3 {
            let fi = Double(i)
            let xCenter = size.width * CGFloat(0.2 + sin(elapsed * 0.08 + fi * 1.1) * 0.3 + fi * 0.25)
            let yCenter = size.height * CGFloat(0.15 + cos(elapsed * 0.06 + fi * 0.9) * 0.08)

            let ellipseRect = CGRect(
                x: xCenter - 80,
                y: yCenter - 120,
                width: 160,
                height: 240
            )

            let gradient = Gradient(stops: [
                .init(color: Color.white.opacity(0.04), location: 0),
                .init(color: Color.white.opacity(0.00), location: 1),
            ])
            ctx.fill(
                Path(ellipseIn: ellipseRect),
                with: .radialGradient(
                    gradient,
                    center: CGPoint(x: xCenter, y: yCenter),
                    startRadius: 0,
                    endRadius: 130
                )
            )
        }
    }
}

#Preview {
    AnimatedBackground()
}
