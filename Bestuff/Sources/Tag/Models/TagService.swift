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

    // MARK: - Duplicates

    static func hasDuplicates(context: ModelContext) throws -> Bool {
        try !findDuplicateGroups(context: context).isEmpty
    }

    static func resolveDuplicates(context: ModelContext) throws {
        let groups = try findDuplicateGroups(context: context)
        for (_, tags) in groups {
            guard let parent = tags.first else { continue }
            let children = tags.dropFirst()
            for child in children {
                // Reassign items to the parent tag
                for item in child.stuffs ?? [] {
                    var itemTags = item.tags ?? []
                    if !itemTags.contains(where: { $0 === parent }) {
                        itemTags.append(parent)
                        item.update(tags: itemTags)
                    }
                }
                // Remove the duplicate tag
                context.delete(child)
            }
        }
    }

    private static func findDuplicateGroups(context: ModelContext) throws -> [String: [Tag]] {
        let allTags: [Tag] = try context.fetch(FetchDescriptor<Tag>())
        let key: (Tag) -> String = { tag in
            tag.name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        }
        let groups = Dictionary(grouping: allTags, by: key)
        return groups.filter { $0.value.count > 1 }
    }
}
