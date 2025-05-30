//
//  BestItem.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/05/30.
//


import AppIntents

struct BestItem: AppEntity {
    var id: String
    var title: String
    var score: Int
    var category: String
    var note: String
    var tags: [String]
    var isPinned: Bool

    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Best Item"

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(title) (\(score))")
    }

    static let defaultQuery = BestItemQuery()
}

extension BestItem {
    init(model: BestItemModel) {
        self.id = model.id
        self.title = model.title
        self.score = model.score
        self.category = model.category
        self.note = model.note
        self.tags = model.tags
        self.isPinned = model.isPinned
    }
}
