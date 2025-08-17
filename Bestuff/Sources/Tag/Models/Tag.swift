import Foundation
import SwiftData

@Model
nonisolated final class Tag {
    private(set) var name: String
    private(set) var typeID: String

    private(set) var stuffs: [Stuff]?

    private init(name: String, typeID: String = TagType.label.rawValue) {
        self.name = name
        self.typeID = typeID
    }

    static func create(name: String, type: TagType = .label) -> Tag {
        .init(name: name, typeID: type.rawValue)
    }

    func update(name: String) {
        self.name = name
    }

    func update(type: TagType) {
        self.typeID = type.rawValue
    }

    static func fetch(byName name: String, type: TagType = .label, in context: ModelContext) throws -> Tag? {
        try context.fetch(
            FetchDescriptor<Tag>(
                predicate: #Predicate {
                    $0.name == name && $0.typeID == type.rawValue
                }
            )
        ).first
    }

    static func findOrCreate(name: String, in context: ModelContext, type: TagType = .label) -> Tag {
        if let existing = try? fetch(byName: name, type: type, in: context) {
            return existing
        }
        let tag = create(name: name, type: type)
        context.insert(tag)
        return tag
    }
}

extension Tag {
    var type: TagType? { TagType(rawValue: typeID) }
}
