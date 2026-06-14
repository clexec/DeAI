import SwiftUI

// MARK: - GlassCard

struct GlassCard<Content: View>: View {
    let content: Content
    var cornerRadius: CGFloat = 20
    var tint: Color?
    var padding: CGFloat = 16

    init(cornerRadius: CGFloat = 20, tint: Color? = nil, padding: CGFloat = 16, @ViewBuilder content: () -> Content) {
        self.cornerRadius = cornerRadius
        self.tint = tint
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .glassCard(cornerRadius: cornerRadius, tint: tint)
    }
}

// MARK: - GlassButton

struct GlassButton: View {
    let icon: String
    let label: String?
    let action: () -> Void
    var shape: ButtonShape = .capsule
    var tint: Color?

    enum ButtonShape { case capsule, circle, rect(CGFloat) }

    init(icon: String, label: String? = nil, tint: Color? = nil, shape: ButtonShape = .capsule, action: @escaping () -> Void) {
        self.icon = icon
        self.label = label
        self.tint = tint
        self.shape = shape
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            Group {
                if let label {
                    Label(label, systemImage: icon)
                        .font(.subheadline.weight(.medium))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                } else {
                    Image(systemName: icon)
                        .font(.title2.weight(.medium))
                        .frame(width: 44, height: 44)
                }
            }
            .foregroundStyle(.white)
        }
        .modifier(GlassShapeModifier(shape: shape, tint: tint))
    }
}

struct GlassShapeModifier: ViewModifier {
    let shape: GlassButton.ButtonShape
    let tint: Color?

    func body(content: Content) -> some View {
        if #available(iOS 26, *) {
            let baseGlass: Glass = tint != nil
                ? Glass.regular.tint(tint!.opacity(0.3)).interactive()
                : Glass.regular.interactive()
            switch shape {
            case .capsule:
                content.glassEffect(baseGlass, in: .capsule)
            case .circle:
                content.glassEffect(baseGlass, in: .circle)
            case .rect(let r):
                content.glassEffect(baseGlass, in: .rect(cornerRadius: r))
            }
        } else {
            switch shape {
            case .capsule:
                content.background(.ultraThinMaterial, in: Capsule())
            case .circle:
                content.background(.ultraThinMaterial, in: Circle())
            case .rect(let r):
                content.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: r))
            }
        }
    }
}

// MARK: - ProviderBadge

struct ProviderBadge: View {
    let provider: AIProviderType
    var size: CGFloat = 32

    var body: some View {
        ZStack {
            Circle()
                .fill(provider.brandColor.opacity(0.25))
                .frame(width: size, height: size)
            Image(systemName: provider.iconName)
                .font(.system(size: size * 0.42, weight: .medium))
                .foregroundStyle(provider.brandColor)
        }
    }
}

// MARK: - StatusDot

struct StatusDot: View {
    let status: AIModel.ConnectionStatus
    var size: CGFloat = 8

    var body: some View {
        Circle()
            .fill(status.color)
            .frame(width: size, height: size)
            .shadow(color: status.color.opacity(0.6), radius: 3)
    }
}

// MARK: - SectionHeader

struct SectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        Label(title, systemImage: icon)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.white.opacity(0.6))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 4)
    }
}
