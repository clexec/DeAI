import SwiftUI

// Replaces missing .glass / .glassProminent ButtonStyle with cross-version fallbacks

struct DeAIGlassButtonStyle: ButtonStyle {
    var tint: Color = .clear
    var prominent: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 13)
            .frame(maxWidth: .infinity)
            .background(
                prominent
                    ? AnyShapeStyle(tint.opacity(configuration.isPressed ? 0.5 : 0.7))
                    : AnyShapeStyle(.ultraThinMaterial)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .opacity(configuration.isPressed ? 0.8 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == DeAIGlassButtonStyle {
    static var deaiGlass: DeAIGlassButtonStyle { DeAIGlassButtonStyle() }
    static func deaiGlassProminent(tint: Color = .blue) -> DeAIGlassButtonStyle {
        DeAIGlassButtonStyle(tint: tint, prominent: true)
    }
}
