import Foundation

struct SessionListState: Equatable {
    var sessions: [Session] = []
    var isLoading: Bool = false
    var errorMessage: String?
}
