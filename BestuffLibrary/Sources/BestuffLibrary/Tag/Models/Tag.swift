import Foundation
import SwiftData

@Model
public final class Tag {
    public private(set) var name: String
    public private(set) var typeID: String

    public private(set) var stuffs: [Stuff]?

    private init(name: String, typeID: String = TagType.label.rawValue) {
        self.name = name
        self.typeID = typeID
    }

    public static func create(name: String, type: TagType = .label) -> Tag {
        .init(name: name, typeID: type.rawValue)
    }

    public func update(name: String) {
        self.name = name
    }

    public func update(type: TagType) {
        self.typeID = type.rawValue
    }

    public static func fetch(byName name: String, type: TagType = .label, in context: ModelContext) throws -> Tag? {
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

    public static func findOrCreate(name: String, in context: ModelContext, type: TagType = .label) -> Tag {
        if let existing = try? fetch(byName: name, type: type, in: context) {
            return existing
        }
        let tag = create(name: name, type: type)
        context.insert(tag)
        return tag
    }
}

extension Tag {
    public var type: TagType? { TagType(rawValue: typeID) }

    public var displayName: String {
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

// MARK: - Deletion helper
extension Tag {
    public func delete() {
        if let context = self.modelContext {
            context.delete(self)
        }
    }
}
