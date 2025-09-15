import Foundation

public enum StuffSort: String, CaseIterable, Identifiable {
    case occurredDateDescending
    case occurredDateAscending
    case titleAscending
    case titleDescending

    public var id: Self { self }

    public var title: String {
        switch self {
        case .occurredDateDescending:
            "Date \u{2193}"
        case .occurredDateAscending:
            "Date \u{2191}"
        case .titleAscending:
            "Title A-Z"
        case .titleDescending:
            "Title Z-A"
        }
    }

    public func areInIncreasingOrder(_ lhs: Stuff, _ rhs: Stuff) -> Bool {
        switch self {
        case .occurredDateDescending:
            lhs.occurredAt > rhs.occurredAt
        case .occurredDateAscending:
            lhs.occurredAt < rhs.occurredAt
        case .titleAscending:
            lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
        case .titleDescending:
            lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedDescending
        }
    }
}
