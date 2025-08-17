import Foundation
import SwiftData

@MainActor
enum TagService {
    static func create(context: ModelContext, name: String, type: TagType = .label) -> Tag {
        Tag.findOrCreate(name: name, in: context, type: type)
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

    static func findDuplicates(context: ModelContext) throws -> [Tag] {
        try findDuplicateGroups(context: context).values.compactMap(\.first)
    }

    static func duplicateGroups(context: ModelContext) throws -> [[Tag]] {
        Array(try findDuplicateGroups(context: context).values)
            .map { $0.sorted { $0.name < $1.name } }
            .sorted { ($0.first?.name ?? "") < ($1.first?.name ?? "") }
    }

    static func mergeDuplicates(tags: [Tag]) throws {
        guard let parent = tags.first else { return }
        let children = tags.dropFirst()
        for child in children {
            for item in child.stuffs ?? [] {
                var itemTags = item.tags ?? []
                if !itemTags.contains(where: { $0 === parent }) {
                    itemTags.append(parent)
                    item.update(tags: itemTags)
                }
            }
        }
        for child in children {
            child.delete()
        }
    }

    static func mergeDuplicates(parent: Tag, children: [Tag]) throws {
        for child in children {
            for item in child.stuffs ?? [] {
                var itemTags = item.tags ?? []
                if !itemTags.contains(where: { $0 === parent }) {
                    itemTags.append(parent)
                    item.update(tags: itemTags)
                }
            }
        }
        for child in children {
            child.delete()
        }
    }

    private static func findDuplicateGroups(context: ModelContext) throws -> [String: [Tag]] {
        let allTags: [Tag] = try context.fetch(FetchDescriptor<Tag>())
        let groups = Dictionary(grouping: allTags) { tag in
            let normalized = tag.name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            return tag.typeID + "::" + normalized
        }
        return groups.filter { $0.value.count > 1 }
    }
}
