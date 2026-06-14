import SwiftUI

// MARK: - Glass effect with automatic iOS 26 / material fallback

extension View {
    @ViewBuilder
    func glassCard(cornerRadius: CGFloat = 20, tint: Color? = nil) -> some View {
        if #available(iOS 26, *) {
            let base: Glass = tint != nil ? .regular.tint(tint!.opacity(0.25)) : .regular
            self.glassEffect(base, in: .rect(cornerRadius: cornerRadius))
        } else {
            self.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius))
        }
    }

    @ViewBuilder
    func glassCapsule(tint: Color? = nil, interactive: Bool = false) -> some View {
        if #available(iOS 26, *) {
            var base: Glass = tint != nil ? .regular.tint(tint!.opacity(0.3)) : .regular
            if interactive { base = base.interactive() }
            self.glassEffect(base, in: .capsule)
        } else {
            self.background(.ultraThinMaterial, in: Capsule())
        }
    }

    @ViewBuilder
    func glassCircle(tint: Color? = nil, interactive: Bool = true) -> some View {
        if #available(iOS 26, *) {
            var base: Glass = interactive ? Glass.regular.interactive() : .regular
            if let tint { base = Glass.regular.tint(tint.opacity(0.5)).interactive() }
            self.glassEffect(base, in: .circle)
        } else {
            if let tint {
                self.background(tint.opacity(0.6), in: Circle())
            } else {
                self.background(.ultraThinMaterial, in: Circle())
            }
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
