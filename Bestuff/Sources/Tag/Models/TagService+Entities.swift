import BestuffLibrary
import SwiftData

extension TagService {
    static func getAll(context: ModelContext) throws -> [TagEntity] {
        try context.fetch(FetchDescriptor<Tag>()).compactMap(TagEntity.init)
    }

    static func get(context: ModelContext, id: String) throws -> TagEntity? {
        let persistentID = try PersistentIdentifier(base64Encoded: id)
        let all: [Tag] = try context.fetch(FetchDescriptor<Tag>())
        guard let tag = all.first(where: { $0.id == persistentID }) else {
            return nil
        }
        return .init(tag)
    }
}
