import SwiftUI

enum Typography {
    // MARK: - Headings
    static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    static let title1 = Font.system(size: 28, weight: .bold, design: .rounded)
    static let title2 = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let title3 = Font.system(size: 20, weight: .semibold, design: .rounded)

    // MARK: - Body
    static let bodyLarge = Font.system(size: 17, weight: .regular, design: .default)
    static let body = Font.system(size: 15, weight: .regular, design: .default)
    static let bodySmall = Font.system(size: 13, weight: .regular, design: .default)

    // MARK: - Labels
    static let label = Font.system(size: 13, weight: .medium, design: .default)
    static let labelSmall = Font.system(size: 11, weight: .medium, design: .default)
    static let labelBold = Font.system(size: 13, weight: .bold, design: .default)

    // MARK: - Buttons
    static let buttonLarge = Font.system(size: 17, weight: .semibold, design: .default)
    static let button = Font.system(size: 15, weight: .semibold, design: .default)
    static let buttonSmall = Font.system(size: 13, weight: .semibold, design: .default)

    // MARK: - Caption
    static let caption = Font.system(size: 12, weight: .regular, design: .default)
    static let captionSmall = Font.system(size: 10, weight: .regular, design: .default)

    // MARK: - Timer/Player
    static let timer = Font.system(size: 24, weight: .medium, design: .monospaced)
    static let timerSmall = Font.system(size: 16, weight: .medium, design: .monospaced)

    // MARK: - Badge
    static let badge = Font.system(size: 10, weight: .bold, design: .default)
}
