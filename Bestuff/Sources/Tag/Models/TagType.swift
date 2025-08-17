import Foundation

enum TagType: String, CaseIterable, Sendable {
    // Keep rawValue "custom" for zero-migration compatibility
    case label = "custom"
    case period
    case resource
}
