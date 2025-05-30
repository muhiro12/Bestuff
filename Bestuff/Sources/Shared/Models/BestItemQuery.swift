//
//  BestItemQuery.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/05/30.
//

import AppIntents
import SwiftData

struct BestItemQuery: EntityQuery {
    func entities(for identifiers: [String]) async throws -> [BestItem] {
        let context = try ModelContext(ModelContainer(for: BestItemModel.self))
        let items = try context.fetch(FetchDescriptor<BestItemModel>(predicate: #Predicate { identifiers.contains($0.id) }))
        return items.map {
            BestItem(
                id: $0.id,
                title: $0.title,
                score: $0.score,
                category: $0.category,
                note: $0.note,
                tags: $0.tags,
                isPinned: $0.isPinned
            )
        }
    }

    func suggestedEntities() async throws -> [BestItem] {
        let context = try ModelContext(ModelContainer(for: BestItemModel.self))
        let items = try context.fetch(FetchDescriptor<BestItemModel>())
        return items.map {
            BestItem(
                id: $0.id,
                title: $0.title,
                score: $0.score,
                category: $0.category,
                note: $0.note,
                tags: $0.tags,
                isPinned: $0.isPinned
            )
        }
    }

    func defaultResult() async -> BestItem? {
        nil
    }
}
