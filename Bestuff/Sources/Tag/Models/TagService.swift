import Foundation
import SwiftData

enum TagService {
    static func create(context: ModelContext, name: String, type: TagType = .label) -> Tag {
        Tag.findOrCreate(name: name, in: context, type: type)
    }

    static func getAll(context: ModelContext) throws -> [TagEntity] {
        try context.fetch(FetchDescriptor<Tag>()).compactMap(TagEntity.init)
    }

    static func getAllLabels(context: ModelContext) throws -> [Tag] {
        let all = try context.fetch(
            FetchDescriptor<Tag>(
                sortBy: [SortDescriptor(\Tag.name, order: .forward)]
            )
        )
        return all.filter { $0.typeID == TagType.label.rawValue }
    }

    static func getUnusedLabels(context: ModelContext) throws -> [Tag] {
        let labels = try getAllLabels(context: context)
        return labels.filter { ($0.stuffs ?? []).isEmpty }
    }

    static func suggestLabels(
        context: ModelContext,
        prefix: String,
        excluding excluded: [Tag] = [],
        limit: Int = 10
    ) throws -> [Tag] {
        let trimmed = prefix.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return []
        }
        let excludedIDs: Set<PersistentIdentifier> = Set(excluded.compactMap(\.id))
        let labels = try getAllLabels(context: context)
        var results = labels.filter { tag in
            tag.name.localizedStandardContains(trimmed) && !excludedIDs.contains(tag.id)
        }
        results.sort { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
        if results.count > limit {
            results = Array(results.prefix(limit))
        }
        return results
    }

    static func mostUsedLabels(
        context: ModelContext,
        excluding excluded: [Tag] = [],
        limit: Int = 10
    ) throws -> [Tag] {
        let excludedIDs: Set<PersistentIdentifier> = Set(excluded.compactMap(\.id))
        let labels = try getAllLabels(context: context).filter { tag in
            !excludedIDs.contains(tag.id)
        }
        let sorted = labels.sorted { lhs, rhs in
            (lhs.stuffs?.count ?? 0) > (rhs.stuffs?.count ?? 0)
        }
        if sorted.count > limit {
            return Array(sorted.prefix(limit))
        }
        return sorted
    }

    static func get(context: ModelContext, id: String) throws -> TagEntity? {
        let persistentID = try PersistentIdentifier(base64Encoded: id)
        let all: [Tag] = try context.fetch(FetchDescriptor<Tag>())
        guard let tag = all.first(where: { $0.id == persistentID }) else {
            return nil
        }
        return .init(tag)
    }

    static func getByName(context: ModelContext, name: String, type: TagType = .label) throws -> Tag? {
        try Tag.fetch(byName: name, type: type, in: context)
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

    // MARK: - Label operations

    static func addLabels(context: ModelContext, to model: Stuff, names: [String]) {
        let labels: [Tag] = names
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map { Tag.findOrCreate(name: $0, in: context, type: .label) }
        var current = model.tags ?? []
        for tag in labels where current.contains(where: { $0.id == tag.id }) == false {
            current.append(tag)
        }
        model.update(tags: current)
    }

    static func removeLabels(from model: Stuff, names: [String]) {
        let targets = Set(names.map { $0.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() })
        let filtered = (model.tags ?? []).filter { tag in
            guard tag.type == .label else { return true }
            return targets.contains(tag.name.lowercased()) == false
        }
        model.update(tags: filtered)
    }
}
