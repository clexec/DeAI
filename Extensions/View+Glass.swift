import SwiftUI

// MARK: - Glass effect with material fallback

extension View {
    func glassCard(cornerRadius: CGFloat = 20, tint: Color? = nil) -> some View {
        self.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
    }

    func glassCapsule(tint: Color? = nil, interactive: Bool = false) -> some View {
        self.background(.ultraThinMaterial, in: Capsule())
    }

    func glassCircle(tint: Color? = nil, interactive: Bool = true) -> some View {
        if let tint {
            self.background(tint.opacity(0.6), in: Circle())
        } else {
            self.background(.ultraThinMaterial, in: Circle())
        }
    }
}

// MARK: - Adaptive foreground on dark glass background

extension View {
    func glassLabel() -> some View {
        self.foregroundStyle(.white)
    }
}

// MARK: - Shimmer / pulse animation

extension View {
    func shimmer(isActive: Bool) -> some View {
        self.modifier(ShimmerModifier(isActive: isActive))
    }
}

struct ShimmerModifier: ViewModifier {
    let isActive: Bool
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        if isActive {
            content
                .overlay(
                    LinearGradient(
                        colors: [.clear, .white.opacity(0.15), .clear],
                        startPoint: UnitPoint(x: phase - 0.3, y: 0),
                        endPoint: UnitPoint(x: phase + 0.3, y: 0)
                    )
                )
                .onAppear {
                    withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) {
                        phase = 1.3
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
        } else {
            content
        }
    }
}

// MARK: - Conditional modifier

extension View {
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition { transform(self) } else { self }
    }
}

// MARK: - Hide keyboard

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
