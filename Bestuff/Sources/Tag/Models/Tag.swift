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

    static func fetch(byName name: String, in context: ModelContext) throws -> Tag? {
        try context.fetch(
            FetchDescriptor<Tag>(
                predicate: #Predicate { $0.name.lowercased() == name.lowercased() }
            )
        ).first
    }

    static func findOrCreate(name: String, in context: ModelContext) -> Tag {
        if let existing = try? fetch(byName: name, in: context) {
            return existing
        }
        let tag = create(name: name)
        context.insert(tag)
        return tag
    }
}
