import SwiftUI

private struct Particle: Identifiable {
    let id = UUID()
    var start: CGPoint
    var end: CGPoint
    var color: Color
    var size: CGFloat
    var delay: Double
}

struct LaunchView: View {
    let onComplete: () -> Void

    @State private var particles: [Particle] = []
    @State private var logoScale: CGFloat = 0.2
    @State private var logoOpacity: Double = 0
    @State private var glowRadius: CGFloat = 0
    @State private var screenWidth: CGFloat = 390
    @State private var screenHeight: CGFloat = 844
    @State private var particleProgress: CGFloat = 0
    @State private var exitOpacity: Double = 1

    private let particleColors: [Color] = [
        Color(red: 0.0, green: 0.5, blue: 1.0),
        Color(red: 0.5, green: 0.0, blue: 0.9),
        Color(red: 0.7, green: 0.7, blue: 1.0),
        Color.white
    ]

    var body: some View {
        GeometryReader { geo in
            ZStack {
                AnimatedBackground()

                // Particles converging
                Canvas { ctx, size in
                    for p in particles {
                        let x = p.start.x + (p.end.x - p.start.x) * particleProgress
                        let y = p.start.y + (p.end.y - p.start.y) * particleProgress
                        let alpha = particleProgress > 0.7 ? 1.0 - Double((particleProgress - 0.7) / 0.3) : 1.0

                        var path = Path(ellipseIn: CGRect(
                            x: x - p.size / 2,
                            y: y - p.size / 2,
                            width: p.size,
                            height: p.size
                        ))
                        ctx.fill(path, with: .color(p.color.opacity(alpha * 0.85)))
                    }
                }

                // Logo
                VStack(spacing: 22) {
                    ZStack {
                        // Outer glow
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color(red: 0.0, green: 0.5, blue: 1.0).opacity(0.5),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 60
                                )
                            )
                            .frame(width: 120, height: 120)
                            .blur(radius: glowRadius)

                        // Icon container
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.1, green: 0.4, blue: 1.0),
                                            Color(red: 0.5, green: 0.0, blue: 0.9)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 88, height: 88)
                                .shadow(color: Color(red: 0.0, green: 0.4, blue: 1.0).opacity(0.6), radius: 20)

                            Image(systemName: "sparkles")
                                .font(.system(size: 40, weight: .light))
                                .foregroundStyle(.white)
                        }
                    }

                    VStack(spacing: 4) {
                        Text("De AI")
                            .font(.system(size: 52, weight: .thin, design: .rounded))
                            .foregroundStyle(.white)
                            .tracking(6)

                        Text("The future of intelligence")
                            .font(.system(size: 14, weight: .light))
                            .foregroundStyle(.white.opacity(0.5))
                            .tracking(2)
                    }
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)
            }
            .opacity(exitOpacity)
            .onAppear {
                let cx = geo.size.width / 2
                let cy = geo.size.height * 0.44
                particles = makeParticles(cx: cx, cy: cy, w: geo.size.width, h: geo.size.height)
                animate()
            }
        }
        .ignoresSafeArea()
    }

    private func makeParticles(cx: CGFloat, cy: CGFloat, w: CGFloat, h: CGFloat) -> [Particle] {
        (0..<70).map { i in
            Particle(
                start: CGPoint(
                    x: CGFloat.random(in: -30...(w + 30)),
                    y: CGFloat.random(in: -60...(h + 60))
                ),
                end: CGPoint(
                    x: cx + CGFloat.random(in: -15...15),
                    y: cy + CGFloat.random(in: -15...15)
                ),
                color: particleColors.randomElement()!,
                size: CGFloat.random(in: 2...6),
                delay: Double(i) * 0.02
            )
        }
    }

    private func animate() {
        // Phase 1: Particles converge (0 → 1.0s)
        withAnimation(.easeIn(duration: 1.0)) {
            particleProgress = 1.0
        }

        // Phase 2: Logo appears (0.7 → 1.5s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.65)) {
                logoScale = 1.0
                logoOpacity = 1.0
                glowRadius = 20
            }
        }

        // Phase 3: Exit (2.6 → 3.2s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.6) {
            withAnimation(.easeInOut(duration: 0.55)) {
                exitOpacity = 0
                logoScale = 1.2
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                onComplete()
            }
        }
    }
}

#Preview {
    LaunchView(onComplete: { })
}
