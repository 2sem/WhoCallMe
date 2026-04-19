import SwiftUI

// MARK: - Color Tokens
// Design System v1.0 — paper · ink · signal amber

extension Color {
    // Paper family — warm neutrals
    static let appPaper       = Color(hex: "#F6F1EA")
    static let appPaper0      = Color(hex: "#FBF7F0")
    static let appPaper2      = Color(hex: "#EFE8DE")
    static let appPaper3      = Color(hex: "#E6DDD0")

    // Ink family — text & structure
    static let appInk         = Color(hex: "#141414")
    static let appInk80       = Color(hex: "#2A2824")
    static let appInk60       = Color(hex: "#5C564D")
    static let appInk40       = Color(hex: "#8A8377")
    static let appInk20       = Color(hex: "#B8B0A3")

    // Signal amber — convert, ring, enriched badge only
    static let appAmber       = Color(red: 0.9578, green: 0.6390, blue: 0.2948) // oklch(0.78 0.14 65)
    static let appAmberDeep   = Color(red: 0.8819, green: 0.4738, blue: 0.1053) // oklch(0.68 0.16 55)
    static let appAmberSoft   = Color(hex: "#F0E7D4")                            // oklch(0.94 0.05 75)

    // Signal mint — safe affirmative (toggle on, restore)
    static let appMint        = Color(red: 0.2944, green: 0.5936, blue: 0.4734) // oklch(0.62 0.09 165)
    static let appMintLight   = Color(red: 0.4706, green: 0.8000, blue: 0.6431) // oklch(0.82 0.08 165)

    // Night — dark canvas
    static let appNight       = Color(hex: "#0F0E0C")
    static let appNight1      = Color(hex: "#1A1916")
    static let appNight2      = Color(hex: "#26241F")
    static let appNightText   = Color(hex: "#F3EEE4")

    // Legacy aliases kept for compatibility during migration
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
}
