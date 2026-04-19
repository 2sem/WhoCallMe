import SwiftUI

// MARK: - Color Tokens
// Design System v1.0 — paper · ink · signal amber
// Light: warm paper canvas. Dark: deep night canvas.

extension Color {
    // Adaptive surface — paper in light, night in dark
    static let appBackground  = Color(adaptive: "#F6F1EA", dark: "#0F0E0C")
    static let appSurface     = Color(adaptive: "#FFFFFF",  dark: "#1A1916")  // cards
    static let appSurface2    = Color(adaptive: "#EFE8DE",  dark: "#26241F")  // ring track, dividers

    // Adaptive text
    static let appTextPrimary   = Color(adaptive: "#141414", dark: "#F3EEE4")
    static let appTextSecondary = Color(adaptive: "#5C564D", dark: "#B8B0A3")
    static let appTextTertiary  = Color(adaptive: "#8A8377", dark: "#5C564D")

    // Semantic tokens
    static let appSuccess       = appMint
    static let appDestructive   = Color(adaptive: "#E64545", dark: "#EF5A5A")
    static let appDestructiveDeep = Color(adaptive: "#C72E2E", dark: "#D84545")
    static let appDisabled      = Color(adaptive: "#C7C0B4", dark: "#3C3832")
    static let appSeparator     = Color(adaptive: "#E6DDD0", dark: "#2F2C26")
    static let appBorder        = Color(adaptive: "#DDD3C5", dark: "#3A362F")

    // Paper family — raw light values (for always-light contexts)
    static let appPaper       = Color(hex: "#F6F1EA")
    static let appPaper0      = Color(hex: "#FBF7F0")
    static let appPaper2      = Color(hex: "#EFE8DE")
    static let appPaper3      = Color(hex: "#E6DDD0")

    // Ink family — raw dark values (for always-dark contexts)
    static let appInk         = Color(hex: "#141414")
    static let appInk80       = Color(hex: "#2A2824")
    static let appInk60       = Color(hex: "#5C564D")
    static let appInk40       = Color(hex: "#8A8377")
    static let appInk20       = Color(hex: "#B8B0A3")

    // Signal amber — convert, ring, enriched badge only (same in both modes)
    static let appAmber       = Color(red: 0.9578, green: 0.6390, blue: 0.2948) // oklch(0.78 0.14 65)
    static let appAmberDeep   = Color(red: 0.8819, green: 0.4738, blue: 0.1053) // oklch(0.68 0.16 55)
    static let appAmberSoft   = Color(hex: "#F0E7D4")

    // Signal mint — safe affirmative (same in both modes)
    static let appMint        = Color(red: 0.2944, green: 0.5936, blue: 0.4734) // oklch(0.62 0.09 165)
    static let appMintLight   = Color(red: 0.4706, green: 0.8000, blue: 0.6431)

    // Night — raw dark values (for always-dark contexts like incoming-call preview)
    static let appNight       = Color(hex: "#0F0E0C")
    static let appNight1      = Color(hex: "#1A1916")
    static let appNight2      = Color(hex: "#26241F")
    static let appNightText   = Color(hex: "#F3EEE4")

    // Legacy aliases
    static let appOrange      = appAmber
    static let appTeal        = appMint
    static let appRingStart   = appAmber
    static let appRingEnd     = appAmberDeep
}

private extension Color {
    init(hex: String) {
        let h = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        let v = UInt64(h, radix: 16) ?? 0
        let r = Double((v >> 16) & 0xFF) / 255
        let g = Double((v >> 8) & 0xFF) / 255
        let b = Double(v & 0xFF) / 255
        self.init(red: r, green: g, blue: b)
    }

    init(adaptive light: String, dark: String) {
        self.init(UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(Color(hex: dark))
                : UIColor(Color(hex: light))
        })
    }
}

// MARK: - Typography Modifiers

struct AppDisplayStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 88, weight: .bold, design: .default))
            .fontDesign(.default)
            .monospacedDigit()
            .tracking(-88 * 0.035)
    }
}

struct AppTitleStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 56, weight: .semibold))
            .tracking(-56 * 0.025)
    }
}

struct AppSectionStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 32, weight: .semibold))
            .tracking(-32 * 0.02)
    }
}

struct AppSubStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 22, weight: .medium))
            .tracking(-22 * 0.01)
    }
}

struct AppBodyStyle: ViewModifier {
    func body(content: Content) -> some View {
        content.font(.system(size: 17, weight: .regular))
    }
}

struct AppCaptionStyle: ViewModifier {
    func body(content: Content) -> some View {
        content.font(.system(size: 14, weight: .regular))
    }
}

struct AppEyebrowStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 13, weight: .medium, design: .monospaced))
            .tracking(13 * 0.14)
            .textCase(.uppercase)
    }
}

extension View {
    func appDisplay()  -> some View { modifier(AppDisplayStyle()) }
    func appTitle()    -> some View { modifier(AppTitleStyle()) }
    func appSection()  -> some View { modifier(AppSectionStyle()) }
    func appSub()      -> some View { modifier(AppSubStyle()) }
    func appBody()     -> some View { modifier(AppBodyStyle()) }
    func appCaption()  -> some View { modifier(AppCaptionStyle()) }
    func appEyebrow()  -> some View { modifier(AppEyebrowStyle()) }
}

// MARK: - Spacing

extension CGFloat {
    static let sp2xs: CGFloat = 4
    static let spXS:  CGFloat = 8
    static let spSM:  CGFloat = 12
    static let spMD:  CGFloat = 16
    static let spLG:  CGFloat = 24
    static let spXL:  CGFloat = 32
    static let sp2XL: CGFloat = 48
    static let sp3XL: CGFloat = 64
}

// MARK: - Corner Radius

extension CGFloat {
    static let radiusSM:   CGFloat = 8
    static let radiusMD:   CGFloat = 14
    static let radiusLG:   CGFloat = 20
    static let radiusXL:   CGFloat = 28
}

// MARK: - Animation Tokens

extension Animation {
    static let appTap:    Animation = .easeOut(duration: 0.12)
    static let appEase:   Animation = .easeInOut(duration: 0.24)
    static let appRing:   Animation = .easeInOut(duration: 0.4)
    static let appSpring: Animation = .spring(response: 0.4, dampingFraction: 0.75)
}

// MARK: - Gradient Helpers

extension LinearGradient {
    static var appAmberGradient: LinearGradient {
        LinearGradient(
            colors: [Color.appAmber, Color.appAmberDeep],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static var appAmberGradientH: LinearGradient {
        LinearGradient(
            colors: [Color.appAmber, Color.appAmberDeep],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    static var appDestructiveGradient: LinearGradient {
        LinearGradient(
            colors: [Color.appDestructive, Color.appDestructiveDeep],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

// MARK: - Reusable Components / Styles

enum AppButtonTone {
    case primary
    case destructive
}

struct AppCapsuleButtonStyle: ButtonStyle {
    let tone: AppButtonTone
    let foreground: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity, minHeight: 56)
            .background(
                tone == .destructive
                    ? LinearGradient.appDestructiveGradient
                    : LinearGradient.appAmberGradient
            )
            .clipShape(Capsule())
            .shadow(
                color: (tone == .destructive ? Color.appDestructive : Color.appAmberDeep)
                    .opacity(configuration.isPressed ? 0.2 : 0.35),
                radius: configuration.isPressed ? 8 : 12,
                y: configuration.isPressed ? 3 : 6
            )
            .scaleEffect(configuration.isPressed ? 0.995 : 1)
            .animation(.appTap, value: configuration.isPressed)
    }
}

struct AppCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: .radiusLG, style: .continuous)
                    .fill(Color.appSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: .radiusLG, style: .continuous)
                            .stroke(Color.appBorder, lineWidth: 1)
                    )
                    .shadow(color: Color.appInk.opacity(0.06), radius: 12, y: 4)
            )
    }
}

extension View {
    func appCard() -> some View {
        modifier(AppCardStyle())
    }
}

struct AppIconBadge: View {
    let systemImage: String
    let backgroundColor: Color?
    let foreground: Color

    init(
        systemImage: String,
        backgroundColor: Color? = nil,
        foreground: Color = .appInk
    ) {
        self.systemImage = systemImage
        self.backgroundColor = backgroundColor
        self.foreground = foreground
    }

    var body: some View {
        ZStack {
            if let backgroundColor {
                RoundedRectangle(cornerRadius: .radiusSM, style: .continuous)
                    .fill(backgroundColor)
            } else {
                RoundedRectangle(cornerRadius: .radiusSM, style: .continuous)
                    .fill(LinearGradient.appAmberGradient)
            }

            Image(systemName: systemImage)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(foreground)
        }
        .frame(width: 32, height: 32)
    }
}

struct AppActionRow: View {
    let title: LocalizedStringKey
    let icon: String
    let iconBackgroundColor: Color?
    let iconForeground: Color

    init(
        title: LocalizedStringKey,
        icon: String,
        iconBackgroundColor: Color? = nil,
        iconForeground: Color = .appInk
    ) {
        self.title = title
        self.icon = icon
        self.iconBackgroundColor = iconBackgroundColor
        self.iconForeground = iconForeground
    }

    var body: some View {
        HStack(spacing: .spMD) {
            AppIconBadge(
                systemImage: icon,
                backgroundColor: iconBackgroundColor,
                foreground: iconForeground
            )
            Text(title)
                .appBody()
                .foregroundStyle(Color.appTextPrimary)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.appTextTertiary)
        }
        .padding(.horizontal, .spMD)
        .frame(height: 52)
    }
}
