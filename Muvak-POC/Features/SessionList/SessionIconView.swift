import SwiftUI

struct SessionIconView: View {
    let sessionType: Session.SessionType

    @State private var isAnimating = false

    private var iconConfig: IconConfig {
        switch sessionType {
        case .relax:
            return IconConfig(
                primaryColor: ColorPalette.secondaryAccent,
                secondaryColor: ColorPalette.primaryAccent.opacity(0.5)
            )
        case .focus:
            return IconConfig(
                primaryColor: ColorPalette.primaryAccent,
                secondaryColor: ColorPalette.secondaryAccent.opacity(0.5)
            )
        case .sleep:
            return IconConfig(
                primaryColor: Color(red: 0.6, green: 0.4, blue: 0.8),
                secondaryColor: ColorPalette.primaryAccent.opacity(0.4)
            )
        case .energy:
            return IconConfig(
                primaryColor: Color(red: 1.0, green: 0.6, blue: 0.2),
                secondaryColor: ColorPalette.secondaryAccent.opacity(0.5)
            )
        }
    }

    var body: some View {
        ZStack {
            // Outer pulsing ring
            Circle()
                .stroke(
                    iconConfig.secondaryColor,
                    lineWidth: 2
                )
                .frame(width: 48, height: 48)
                .scaleEffect(isAnimating ? 1.15 : 1.0)
                .opacity(isAnimating ? 0.3 : 0.6)

            // Inner gradient circle
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            iconConfig.primaryColor.opacity(0.8),
                            iconConfig.primaryColor.opacity(0.3)
                        ]),
                        center: .center,
                        startRadius: 0,
                        endRadius: 20
                    )
                )
                .frame(width: 40, height: 40)
                .scaleEffect(isAnimating ? 1.05 : 0.95)

            // Center icon
            sessionIcon
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.white)
                .scaleEffect(isAnimating ? 1.1 : 1.0)
        }
        .frame(width: 60, height: 60)
        .background(ColorPalette.surfaceBackground)
        .cornerRadius(8)
        .onAppear {
            withAnimation(
                .easeInOut(duration: 2.0)
                .repeatForever(autoreverses: true)
            ) {
                isAnimating = true
            }
        }
    }

    @ViewBuilder
    private var sessionIcon: some View {
        switch sessionType {
        case .relax:
            WaveformIcon()
        case .focus:
            TargetIcon()
        case .sleep:
            MoonIcon()
        case .energy:
            BoltIcon()
        }
    }

    private struct IconConfig {
        let primaryColor: Color
        let secondaryColor: Color
    }
}

// MARK: - Custom Icons

struct WaveformIcon: View {
    @State private var phase: CGFloat = 0

    var body: some View {
        Canvas { context, size in
            let midY = size.height / 2
            let amplitude: CGFloat = 6
            let wavelength: CGFloat = size.width / 2

            var path = Path()
            path.move(to: CGPoint(x: 0, y: midY))

            for x in stride(from: 0, through: size.width, by: 1) {
                let relativeX = x / wavelength
                let y = midY + sin((relativeX + phase) * .pi * 2) * amplitude
                path.addLine(to: CGPoint(x: x, y: y))
            }

            context.stroke(
                path,
                with: .color(.white),
                style: StrokeStyle(lineWidth: 2, lineCap: .round)
            )
        }
        .frame(width: 24, height: 16)
        .onAppear {
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                phase = 1
            }
        }
    }
}

struct TargetIcon: View {
    @State private var rotation: Double = 0

    var body: some View {
        ZStack {
            // Outer ring
            Circle()
                .stroke(Color.white.opacity(0.5), lineWidth: 1.5)
                .frame(width: 18, height: 18)

            // Inner ring
            Circle()
                .stroke(Color.white.opacity(0.7), lineWidth: 1.5)
                .frame(width: 10, height: 10)

            // Center dot
            Circle()
                .fill(Color.white)
                .frame(width: 4, height: 4)

            // Rotating indicator
            Circle()
                .fill(Color.white)
                .frame(width: 3, height: 3)
                .offset(y: -7)
                .rotationEffect(.degrees(rotation))
        }
        .onAppear {
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

struct MoonIcon: View {
    @State private var glowing = false

    var body: some View {
        ZStack {
            // Glow effect
            Image(systemName: "moon.fill")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.3))
                .blur(radius: glowing ? 4 : 2)
                .scaleEffect(glowing ? 1.2 : 1.0)

            // Main moon
            Image(systemName: "moon.fill")
                .font(.system(size: 16))
                .foregroundColor(.white)

            // Stars
            ForEach(0..<3, id: \.self) { index in
                StarView(index: index)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                glowing = true
            }
        }
    }
}

struct StarView: View {
    let index: Int
    @State private var opacity: Double = 0.3

    private var offset: CGSize {
        switch index {
        case 0: return CGSize(width: 8, height: -6)
        case 1: return CGSize(width: -7, height: -4)
        default: return CGSize(width: 6, height: 5)
        }
    }

    private var size: CGFloat {
        switch index {
        case 0: return 3
        case 1: return 2
        default: return 2.5
        }
    }

    var body: some View {
        Image(systemName: "sparkle")
            .font(.system(size: size))
            .foregroundColor(.white)
            .opacity(opacity)
            .offset(offset)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 0.8 + Double(index) * 0.3)
                    .repeatForever(autoreverses: true)
                    .delay(Double(index) * 0.2)
                ) {
                    opacity = 1.0
                }
            }
    }
}

struct BoltIcon: View {
    @State private var flash = false

    var body: some View {
        ZStack {
            // Glow
            Image(systemName: "bolt.fill")
                .font(.system(size: 18))
                .foregroundColor(.white.opacity(flash ? 0.6 : 0.2))
                .blur(radius: flash ? 6 : 3)
                .scaleEffect(flash ? 1.3 : 1.0)

            // Main bolt
            Image(systemName: "bolt.fill")
                .font(.system(size: 18))
                .foregroundColor(.white)
                .scaleEffect(flash ? 1.05 : 1.0)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.15).repeatForever(autoreverses: true).delay(2)) {
                flash = true
            }
        }
    }
}

#Preview {
    ZStack {
        ColorPalette.primaryBackground
            .ignoresSafeArea()

        VStack(spacing: 20) {
            HStack(spacing: 20) {
                SessionIconView(sessionType: .relax)
                SessionIconView(sessionType: .focus)
            }
            HStack(spacing: 20) {
                SessionIconView(sessionType: .sleep)
                SessionIconView(sessionType: .energy)
            }
        }
    }
}
