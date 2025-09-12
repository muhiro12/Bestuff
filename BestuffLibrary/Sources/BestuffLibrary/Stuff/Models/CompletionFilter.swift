import Foundation

public enum CompletionFilter: String, CaseIterable, Identifiable {
    case all
    case completed
    case pending

    public var id: Self { self }

    public var title: String {
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
