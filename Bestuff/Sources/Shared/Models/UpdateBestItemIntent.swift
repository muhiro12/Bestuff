//
//  UpdateBestItemIntent.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/05/30.
//

import AppIntents
import SwiftData

struct UpdateBestItemIntent: AppIntent {
    static let title: LocalizedStringResource = "Update Best Item"

    @Parameter(title: "ID") var id: String
    @Parameter(title: "Title") var title: String
    @Parameter(title: "Score") var score: Int
    @Parameter(title: "Category") var category: String
    @Parameter(title: "Note") var note: String
    @Parameter(title: "Tags") var tags: [String]
    @Parameter(title: "Is Pinned") var isPinned: Bool

    func perform() async throws -> some IntentResult & ReturnsValue<BestItem> {
        let context = try ModelContext(ModelContainer(for: BestItemModel.self))
        return .result(value: try Self.perform(
            id: id,
            title: title,
            score: score,
            category: category,
            note: note,
            tags: tags,
            isPinned: isPinned,
            context: context
        ))
    }

    static func perform(
        id: String,
        title: String,
        score: Int,
        category: String,
        note: String,
        tags: [String],
        isPinned: Bool,
        context: ModelContext
    ) throws -> BestItem {
        guard let model = try context.fetch(FetchDescriptor<BestItemModel>(predicate: #Predicate { $0.id == id })).first else {
            throw NSError(domain: "BestItemIntent", code: 404, userInfo: [NSLocalizedDescriptionKey: "Item not found"])
        }

        model.update(
            title: title,
            score: score,
            category: category,
            note: note,
            tags: tags,
            imageData: nil,
            purchaseDate: nil,
            price: nil,
            recommendLevel: 3,
            isPinned: isPinned
        )

        return BestItem(model: model)
    }
}
