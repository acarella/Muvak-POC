import Foundation
import Combine

@MainActor
final class SessionDetailStore: ObservableObject {
    @Published private(set) var state: SessionDetailState

    private let reducer: (inout SessionDetailState, SessionDetailAction, SessionDetailDependencies) -> AnyPublisher<SessionDetailAction, Never>?
    private let dependencies: SessionDetailDependencies
    private var cancellables = Set<AnyCancellable>()

    init(
        initialState: SessionDetailState = SessionDetailState(),
        reducer: @escaping (inout SessionDetailState, SessionDetailAction, SessionDetailDependencies) -> AnyPublisher<SessionDetailAction, Never>? = sessionDetailReducer,
        dependencies: SessionDetailDependencies
    ) {
        self.state = initialState
        self.reducer = reducer
        self.dependencies = dependencies
    }

    func send(_ action: SessionDetailAction) {
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
