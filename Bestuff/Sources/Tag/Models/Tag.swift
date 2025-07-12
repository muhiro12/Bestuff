import Foundation
import SwiftData

@Model
nonisolated final class Tag {
    private(set) var name: String

    private(set) var stuffs: [Stuff]?

    private init(name: String) {
        self.name = name
    }

    static func create(name: String) -> Tag {
        .init(name: name)
    }

    func update(name: String) {
        self.name = name
    }
}
