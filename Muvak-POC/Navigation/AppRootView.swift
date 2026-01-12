import SwiftUI

struct AppRootView: View {
    @State private var navigationPath = NavigationPath()

    @StateObject private var sessionListStore = SessionListStore(
        dependencies: .live
    )

    var body: some View {
        NavigationStack(path: $navigationPath) {
            SessionListView(store: sessionListStore) { session in
                navigationPath.append(session)
            }
            .navigationDestination(for: Session.self) { session in
                SessionDetailView(
                    store: SessionDetailStore(dependencies: .live),
                    sessionId: session.id,
                    onBack: { navigationPath.removeLast() },
                    onEndSession: { navigationPath.removeLast() }
                )
                .navigationBarHidden(true)
            }
        }
    }
}
