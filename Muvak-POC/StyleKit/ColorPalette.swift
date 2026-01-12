import SwiftUI

enum ColorPalette {
    // MARK: - Backgrounds
    static let primaryBackground = Color(hex: "0D0D12")
    static let cardBackground = Color(hex: "1A1A24")
    static let surfaceBackground = Color(hex: "252530")

    // MARK: - Accents
    static let primaryAccent = Color(hex: "00D9FF")
    static let secondaryAccent = Color(hex: "00C853")
    static let tertiaryAccent = Color(hex: "8B5CF6")

    // MARK: - Text
    static let textPrimary = Color.white
    static let textSecondary = Color(hex: "9CA3AF")
    static let textTertiary = Color(hex: "6B7280")
    static let textDisabled = Color(hex: "4B5563")

    // MARK: - Tags
    static let tagBackground = Color(hex: "1F1F2E")
    static let tagBorder = Color(hex: "3D3D4D")
    static let tagText = Color(hex: "E5E7EB")

    // MARK: - Semantic
    static let error = Color(hex: "EF4444")
    static let success = Color(hex: "10B981")
    static let warning = Color(hex: "F59E0B")

    // MARK: - Player
    static let playerOverlay = Color.black.opacity(0.4)
    static let progressTrack = Color(hex: "374151")
    static let progressFill = Color(hex: "00D9FF")

    // MARK: - Buttons
    static let buttonOutline = Color(hex: "00D9FF")
    static let buttonFill = Color(hex: "00D9FF")
    static let buttonDisabled = Color(hex: "374151")

    // MARK: - Borders & Dividers
    static let border = Color(hex: "374151")
    static let divider = Color(hex: "1F2937")
}

// MARK: - Color Extension for Hex Support

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
