import SwiftUI

struct AudioVisualizerView: View {
    let isPlaying: Bool
    let barCount: Int
    let barSpacing: CGFloat
    let barWidth: CGFloat
    let minHeight: CGFloat
    let maxHeight: CGFloat

    init(
        isPlaying: Bool,
        barCount: Int = 40,
        barSpacing: CGFloat = 3,
        barWidth: CGFloat = 4,
        minHeight: CGFloat = 8,
        maxHeight: CGFloat = 80
    ) {
        self.isPlaying = isPlaying
        self.barCount = barCount
        self.barSpacing = barSpacing
        self.barWidth = barWidth
        self.minHeight = minHeight
        self.maxHeight = maxHeight
    }

    var body: some View {
        HStack(alignment: .center, spacing: barSpacing) {
            ForEach(0..<barCount, id: \.self) { index in
                AudioBarView(
                    isPlaying: isPlaying,
                    barWidth: barWidth,
                    minHeight: minHeight,
                    maxHeight: maxHeight,
                    index: index
                )
            }
        }
    }
}

struct AudioBarView: View {
    let isPlaying: Bool
    let barWidth: CGFloat
    let minHeight: CGFloat
    let maxHeight: CGFloat
    let index: Int

    @State private var animatedHeight: CGFloat = 0
    @State private var isAnimating = false

    private var baseHeight: CGFloat {
        // Create a wave pattern for idle state
        let normalizedIndex = Double(index) / 40.0
        let wave = sin(normalizedIndex * .pi * 2) * 0.3 + 0.4
        return minHeight + (maxHeight - minHeight) * wave * 0.3
    }

    private var animationDuration: Double {
        // Vary duration based on position for more organic feel
        0.3 + Double(index % 5) * 0.1
    }

    private var animationDelay: Double {
        // Stagger animations for wave effect
        Double(index) * 0.02
    }

    var body: some View {
        RoundedRectangle(cornerRadius: barWidth / 2)
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        ColorPalette.primaryAccent,
                        ColorPalette.secondaryAccent
                    ]),
                    startPoint: .bottom,
                    endPoint: .top
                )
            )
            .frame(width: barWidth, height: animatedHeight)
            .animation(
                isPlaying
                    ? .easeInOut(duration: animationDuration).repeatForever(autoreverses: true)
                    : .easeOut(duration: 0.3),
                value: animatedHeight
            )
            .onAppear {
                animatedHeight = baseHeight
            }
            .onChange(of: isPlaying) { _, newValue in
                if newValue {
                    startAnimation()
                } else {
                    stopAnimation()
                }
            }
    }

    private func startAnimation() {
        // Random target height for each bar
        let randomFactor = Double.random(in: 0.4...1.0)
        withAnimation(.easeInOut(duration: animationDuration).delay(animationDelay)) {
            animatedHeight = minHeight + (maxHeight - minHeight) * randomFactor
        }

        // Continue randomizing heights while playing
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration + animationDelay) {
            if isPlaying {
                startAnimation()
            }
        }
    }

    private func stopAnimation() {
        withAnimation(.easeOut(duration: 0.3)) {
            animatedHeight = baseHeight
        }
    }
}

// MARK: - Circular Visualizer Alternative

struct CircularAudioVisualizerView: View {
    let isPlaying: Bool
    let ringCount: Int

    init(isPlaying: Bool, ringCount: Int = 3) {
        self.isPlaying = isPlaying
        self.ringCount = ringCount
    }

    var body: some View {
        ZStack {
            ForEach(0..<ringCount, id: \.self) { index in
                PulsingRingView(
                    isPlaying: isPlaying,
                    index: index,
                    totalRings: ringCount
                )
            }

            // Center icon
            Image(systemName: isPlaying ? "waveform" : "waveform")
                .font(.system(size: 32, weight: .light))
                .foregroundColor(ColorPalette.primaryAccent)
                .scaleEffect(isPlaying ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: isPlaying)
        }
    }
}

struct PulsingRingView: View {
    let isPlaying: Bool
    let index: Int
    let totalRings: Int

    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 0.6

    private var baseSize: CGFloat {
        60 + CGFloat(index) * 40
    }

    private var animationDuration: Double {
        1.5 + Double(index) * 0.3
    }

    var body: some View {
        Circle()
            .stroke(
                LinearGradient(
                    gradient: Gradient(colors: [
                        ColorPalette.primaryAccent.opacity(0.6),
                        ColorPalette.secondaryAccent.opacity(0.3)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 2
            )
            .frame(width: baseSize, height: baseSize)
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                if isPlaying {
                    startPulsing()
                }
            }
            .onChange(of: isPlaying) { _, newValue in
                if newValue {
                    startPulsing()
                } else {
                    stopPulsing()
                }
            }
    }

    private func startPulsing() {
        withAnimation(
            .easeInOut(duration: animationDuration)
            .repeatForever(autoreverses: true)
            .delay(Double(index) * 0.2)
        ) {
            scale = 1.15
            opacity = 0.3
        }
    }

    private func stopPulsing() {
        withAnimation(.easeOut(duration: 0.3)) {
            scale = 1.0
            opacity = 0.6
        }
    }
}

#Preview {
    ZStack {
        ColorPalette.primaryBackground
            .ignoresSafeArea()

        VStack(spacing: 40) {
            Text("Bar Visualizer")
                .foregroundColor(.white)
            AudioVisualizerView(isPlaying: true)
                .frame(height: 100)

            Text("Circular Visualizer")
                .foregroundColor(.white)
            CircularAudioVisualizerView(isPlaying: true)
                .frame(height: 200)
        }
    }
}
