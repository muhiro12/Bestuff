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

    func perform() async throws -> some IntentResult & ReturnsValue<BestItem> {
        return .result(value: try Self.perform(
            title: title,
            score: score,
            category: category,
            note: note,
            tags: tags
        ))
    }

    static func perform(
        title: String,
        score: Int,
        category: String = "General",
        note: String = "",
        tags: [String] = [],
        imageData: Data? = nil,
        purchaseDate: Date? = nil,
        price: Double? = nil,
        recommendLevel: Int = 3
    ) throws -> BestItem {
        let context = try ModelContext(ModelContainer(for: BestItemModel.self))
        let model = BestItemModel.create(
            context: context,
            title: title,
            score: score,
            category: category,
            note: note,
            tags: tags,
            imageData: imageData,
            purchaseDate: purchaseDate,
            price: price,
            recommendLevel: recommendLevel
        )
        return BestItem(model: model)
    }
}
