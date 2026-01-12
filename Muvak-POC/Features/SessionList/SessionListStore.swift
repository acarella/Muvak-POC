import Foundation
import Combine

@MainActor
final class SessionListStore: ObservableObject {
    @Published private(set) var state: SessionListState

    private let reducer: (inout SessionListState, SessionListAction, SessionListDependencies) -> AnyPublisher<SessionListAction, Never>?
    private let dependencies: SessionListDependencies
    private var cancellables = Set<AnyCancellable>()

    init(
        initialState: SessionListState = SessionListState(),
        reducer: @escaping (inout SessionListState, SessionListAction, SessionListDependencies) -> AnyPublisher<SessionListAction, Never>? = sessionListReducer,
        dependencies: SessionListDependencies
    ) {
        self.state = initialState
        self.reducer = reducer
        self.dependencies = dependencies
    }

    func send(_ action: SessionListAction) {
        let effect = reducer(&state, action, dependencies)

        effect?
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newAction in
                Task { @MainActor in
                    self?.send(newAction)
                }
            }
            .store(in: &cancellables)
    }
}
