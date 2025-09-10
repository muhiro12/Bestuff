import Foundation
import SwiftData

@Model
final class Tag {
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
        let typeID = type.rawValue
        let targetName = name
        return try context.fetch(
            FetchDescriptor<Tag>(
                predicate: #Predicate {
                    $0.name == targetName && $0.typeID == typeID
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

    var displayName: String {
        switch type {
        case .period:
            name
        case .resource:
            name
        case .label, .none:
            name
        }
    }
}
