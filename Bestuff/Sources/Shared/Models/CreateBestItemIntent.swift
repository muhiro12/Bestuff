//
//  CreateBestItemIntent.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/05/30.
//

import AppIntents
import SwiftData

struct CreateBestItemIntent: AppIntent {
    static let title: LocalizedStringResource = "Create Best Item"

    @Parameter(title: "Title") var title: String
    @Parameter(title: "Score") var score: Int
    @Parameter(title: "Category", default: "General") var category: String
    @Parameter(title: "Note") var note: String
    @Parameter(title: "Tags") var tags: [String]
    @Parameter(title: "Is Pinned") var isPinned: Bool

    func perform() async throws -> some IntentResult & ReturnsValue<BestItem> {
        return .result(value: try Self.perform(
            title: title,
            score: score,
            category: category,
            note: note,
            tags: tags,
            isPinned: isPinned
        ))
    }

    static func perform(
        title: String,
        score: Int,
        category: String,
        note: String,
        tags: [String],
        isPinned: Bool
    ) throws -> BestItem {
        let context = try ModelContext(ModelContainer(for: BestItemModel.self))
        let model = BestItemModel.create(
            context: context,
            title: title,
            score: score,
            category: category,
            note: note,
            tags: tags,
            imageData: nil,
            purchaseDate: nil,
            price: nil,
            recommendLevel: 3
        )
        return BestItem(model: model)
    }
}
