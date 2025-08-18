import Foundation

enum CompletionFilter: String, CaseIterable, Identifiable {
    case all
    case completed
    case pending

    var id: Self { self }

    var title: String {
        switch self {
        case .all:
            "All"
        case .completed:
            "Completed"
        case .pending:
            "Pending"
        }
    }
}
