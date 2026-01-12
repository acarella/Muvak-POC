import SwiftUI

struct SessionDetailView: View {
    @ObservedObject var store: SessionDetailStore
    let sessionId: String
    let onBack: () -> Void
    let onEndSession: () -> Void

    var body: some View {
        ZStack {
            ColorPalette.primaryBackground
                .ignoresSafeArea()

            if store.state.isLoading && store.state.session == nil {
                loadingView
            } else if let error = store.state.errorMessage {
                errorView(message: error)
            } else {
                contentView
            }
        }
        .onAppear {
            store.send(.viewAppeared(sessionId: sessionId))
        }
        .onDisappear {
            store.send(.viewDisappeared)
        }
    }

    // MARK: - Loading View

    private var loadingView: some View {
        ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: ColorPalette.primaryAccent))
            .scaleEffect(1.5)
    }

    // MARK: - Error View

    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(ColorPalette.error)

            Text(message)
                .font(Typography.body)
                .foregroundColor(ColorPalette.textSecondary)
                .multilineTextAlignment(.center)

            Button("Retry") {
                store.send(.viewAppeared(sessionId: sessionId))
            }
            .font(Typography.button)
            .foregroundColor(ColorPalette.primaryAccent)
        }
        .padding()
    }

    // MARK: - Content View

    private var contentView: some View {
        ScrollView {
            VStack(spacing: 20) {
                navigationBar
                tagsRow
                mediaPlayerCard
                actionButtonsRow
                endSessionButton
                performanceCard
                experienceCard
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
        }
    }

    // MARK: - Navigation Bar

    private var navigationBar: some View {
        HStack(spacing: 12) {
            Button(action: {
                store.send(.backButtonTapped)
                onBack()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(ColorPalette.textPrimary)
                    .frame(width: 40, height: 40)
                    .background(ColorPalette.cardBackground)
                    .clipShape(Circle())
            }

            Text(store.state.session?.title ?? "Session")
                .font(Typography.title3)
                .foregroundColor(ColorPalette.textPrimary)

            tutorialBadge

            Spacer()

            HStack(spacing: 12) {
                Button(action: { store.send(.searchTapped) }) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 18))
                        .foregroundColor(ColorPalette.textPrimary)
                }

                Button(action: { store.send(.menuTapped) }) {
                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: 18))
                        .foregroundColor(ColorPalette.textPrimary)
                }
            }
        }
        .padding(.vertical, 8)
    }

    private var tutorialBadge: some View {
        Text("TUTORIAL")
            .font(Typography.badge)
            .foregroundColor(ColorPalette.textPrimary)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(ColorPalette.primaryAccent)
            .cornerRadius(4)
    }

    // MARK: - Tags Row

    private var tagsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(store.state.session?.tags ?? [], id: \.self) { tag in
                    TagView(text: tag)
                }
            }
        }
    }

    // MARK: - Media Player Card

    private var mediaPlayerCard: some View {
        VStack(spacing: 0) {
            ZStack {
                ColorPalette.cardBackground

                AudioVisualizerView(isPlaying: store.state.isPlaying)
                    .frame(height: 100)
                    .padding(.horizontal, 20)
            }
            .frame(height: 220)
            .cornerRadius(12, corners: [.topLeft, .topRight])

            HStack {
                Button(action: { store.send(.playPauseTapped) }) {
                    Image(systemName: store.state.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 16))
                        .foregroundColor(ColorPalette.textPrimary)
                }

                Text(store.state.formattedElapsedTime)
                    .font(Typography.timerSmall)
                    .foregroundColor(ColorPalette.textPrimary)

                Spacer()

                HStack(spacing: 20) {
                    Button(action: { store.send(.volumeTapped) }) {
                        Image(systemName: "speaker.wave.2")
                            .font(.system(size: 16))
                            .foregroundColor(ColorPalette.textSecondary)
                    }

                    Button(action: { store.send(.fullscreenTapped) }) {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .font(.system(size: 16))
                            .foregroundColor(ColorPalette.textSecondary)
                    }

                    Button(action: { store.send(.moreOptionsTapped) }) {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 16))
                            .foregroundColor(ColorPalette.textSecondary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(ColorPalette.surfaceBackground)
            .cornerRadius(12, corners: [.bottomLeft, .bottomRight])
        }
    }

    // MARK: - Action Buttons Row

    private var actionButtonsRow: some View {
        HStack {
            Spacer()

            ActionButton(
                icon: "repeat",
                isActive: false,
                action: { store.send(.repeatTapped) }
            )

            Spacer()

            ActionButton(
                icon: "forward.end",
                isActive: false,
                action: { store.send(.skipTapped) }
            )

            Spacer()

            ActionButton(
                icon: store.state.isBookmarked ? "bookmark.fill" : "bookmark",
                isActive: store.state.isBookmarked,
                action: { store.send(.bookmarkTapped) }
            )

            Spacer()

            ActionButton(
                icon: store.state.isDownloaded ? "arrow.down.circle.fill" : "arrow.down.circle",
                isActive: store.state.isDownloaded,
                action: { store.send(.downloadTapped) }
            )

            Spacer()

            ActionButton(
                icon: store.state.isLiked ? "hand.thumbsup.fill" : "hand.thumbsup",
                isActive: store.state.isLiked,
                action: { store.send(.likeTapped) }
            )

            Spacer()

            ActionButton(
                icon: store.state.isDisliked ? "hand.thumbsdown.fill" : "hand.thumbsdown",
                isActive: store.state.isDisliked,
                action: { store.send(.dislikeTapped) }
            )

            Spacer()
        }
        .padding(.vertical, 8)
    }

    // MARK: - End Session Button

    private var endSessionButton: some View {
        Button(action: {
            store.send(.endSessionTapped)
            onEndSession()
        }) {
            Text("End Session")
                .font(Typography.button)
                .foregroundColor(ColorPalette.primaryAccent)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(ColorPalette.primaryAccent, lineWidth: 1)
                )
        }
    }

    // MARK: - Performance Card

    private var performanceCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("PERFORMANCE")
                .font(Typography.labelBold)
                .foregroundColor(ColorPalette.secondaryAccent)

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Today")
                        .font(Typography.title3)
                        .foregroundColor(ColorPalette.textPrimary)

                    if let performance = store.state.performance {
                        Text(formatDate(performance.date))
                            .font(Typography.caption)
                            .foregroundColor(ColorPalette.textSecondary)
                    }
                }

                Spacer()

                if let performance = store.state.performance {
                    CircularProgressView(
                        progress: performance.progressPercentage,
                        label: "\(performance.todayMinutes)mins"
                    )
                }
            }

            if let performance = store.state.performance {
                HStack(spacing: 12) {
                    ForEach(performance.weeklyProgress) { day in
                        VStack(spacing: 4) {
                            Circle()
                                .fill(day.isCompleted ? ColorPalette.secondaryAccent : ColorPalette.progressTrack)
                                .frame(width: 10, height: 10)
                            Text(day.dayLetter)
                                .font(Typography.captionSmall)
                                .foregroundColor(ColorPalette.textTertiary)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(ColorPalette.cardBackground)
        .cornerRadius(12)
    }

    // MARK: - Experience Card

    private var experienceCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("EXPERIENCE")
                    .font(Typography.labelBold)
                    .foregroundColor(ColorPalette.secondaryAccent)

                Spacer()

                if let experience = store.state.experience {
                    HStack(spacing: 4) {
                        Text("Level up in")
                            .font(Typography.caption)
                            .foregroundColor(ColorPalette.textSecondary)
                        Text("\(experience.minutesToNextLevel)mins")
                            .font(Typography.caption)
                            .foregroundColor(ColorPalette.secondaryAccent)
                    }
                }
            }

            if let experience = store.state.experience {
                Text(experience.level.rawValue)
                    .font(Typography.title3)
                    .foregroundColor(ColorPalette.textPrimary)

                Text("Meditation experience")
                    .font(Typography.caption)
                    .foregroundColor(ColorPalette.textSecondary)

                Text(experience.description)
                    .font(Typography.bodySmall)
                    .foregroundColor(ColorPalette.textSecondary)
                    .lineLimit(2)
            }
        }
        .padding(16)
        .background(ColorPalette.cardBackground)
        .cornerRadius(12)
    }

    // MARK: - Helpers

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM, yyyy"
        return formatter.string(from: date)
    }
}

// MARK: - Subviews

struct TagView: View {
    let text: String

    var body: some View {
        Text(text)
            .font(Typography.labelSmall)
            .foregroundColor(ColorPalette.tagText)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(ColorPalette.tagBackground)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(ColorPalette.tagBorder, lineWidth: 1)
            )
            .cornerRadius(20)
    }
}

struct ActionButton: View {
    let icon: String
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(isActive ? ColorPalette.primaryAccent : ColorPalette.textSecondary)
        }
        .frame(width: 44, height: 44)
    }
}

struct CircularProgressView: View {
    let progress: Double
    let label: String

    var body: some View {
        ZStack {
            Circle()
                .stroke(ColorPalette.progressTrack, lineWidth: 4)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(ColorPalette.secondaryAccent, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))

            Text(label)
                .font(Typography.captionSmall)
                .foregroundColor(ColorPalette.textPrimary)
        }
        .frame(width: 70, height: 70)
    }
}

// MARK: - Corner Radius Extension

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
