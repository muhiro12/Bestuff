import Foundation
import SwiftData

@MainActor
enum TagService {
    static func create(context: ModelContext, name: String) -> Tag {
        Tag.findOrCreate(name: name, in: context)
    }

    static func getAll(context: ModelContext) throws -> [TagEntity] {
        try context.fetch(FetchDescriptor<Tag>()).compactMap(TagEntity.init)
    }

    static func get(context: ModelContext, id: String) throws -> TagEntity? {
        let persistentID = try PersistentIdentifier(base64Encoded: id)
        guard let tag = try context.fetch(
            FetchDescriptor<Tag>(predicate: #Predicate { $0.id == persistentID })
        ).first else {
            return nil
        }
        return .init(tag)
    }

    static func update(model: Tag, name: String) -> Tag {
        model.update(name: name)
        return model
    }
}
