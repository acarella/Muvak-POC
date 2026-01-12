import SwiftUI

struct SessionListView: View {
    @ObservedObject var store: SessionListStore
    let onSessionSelected: (Session) -> Void

    var body: some View {
        ZStack {
            ColorPalette.primaryBackground
                .ignoresSafeArea()

            if store.state.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: ColorPalette.primaryAccent))
            } else if let error = store.state.errorMessage {
                errorView(message: error)
            } else {
                sessionsList
            }
        }
        .onAppear {
            store.send(.viewAppeared)
        }
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(ColorPalette.error)

            Text(message)
                .font(Typography.body)
                .foregroundColor(ColorPalette.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }

    private var sessionsList: some View {
        ScrollView {
            VStack(spacing: 12) {
                Text("Sessions")
                    .font(Typography.title1)
                    .foregroundColor(ColorPalette.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 16)

                ForEach(store.state.sessions) { session in
                    SessionRowView(session: session) {
                        store.send(.sessionTapped(session))
                        onSessionSelected(session)
                    }
                }
            }
            .padding(.bottom, 32)
        }
    }
}

struct SessionRowView: View {
    let session: Session
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                SessionIconView(sessionType: session.type)

                VStack(alignment: .leading, spacing: 4) {
                    Text(session.title)
                        .font(Typography.bodyLarge)
                        .foregroundColor(ColorPalette.textPrimary)

                    Text(session.type.rawValue)
                        .font(Typography.caption)
                        .foregroundColor(ColorPalette.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(ColorPalette.textTertiary)
            }
            .padding(12)
            .background(ColorPalette.cardBackground)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 16)
    }
}
