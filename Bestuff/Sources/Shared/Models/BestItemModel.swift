//
//  BestItemModel.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/04/21.
//

import SwiftUI
import SwiftData

@Model
final class BestItemModel {
    private(set) var id = UUID().uuidString
    private(set) var title = ""
    private(set) var score = 0
    private(set) var category = "General"
    private(set) var note = ""
    private(set) var tags: [String] = []
    private(set) var imageData: Data?
    private(set) var purchaseDate: Date?
    private(set) var price: Double?
    private(set) var recommendLevel = 3
    private(set) var isPinned = false

    private(set) var createdTimestamp = Date.now
    private(set) var modifiedTimestamp = Date.now

    private init() {}

    @discardableResult
    static func create(
        context: ModelContext,
        title: String,
        score: Int,
        category: String = "General",
        note: String = "",
        tags: [String] = [],
        imageData: Data? = nil,
        purchaseDate: Date? = nil,
        price: Double? = nil,
        recommendLevel: Int = 3
    ) -> BestItemModel {
        let item = BestItemModel()
        context.insert(item)
        item.title = title
        item.score = score
        item.category = category
        item.note = note
        item.tags = tags
        item.imageData = imageData
        item.purchaseDate = purchaseDate
        item.price = price
        item.recommendLevel = recommendLevel
        item.createdTimestamp = .now
        item.modifiedTimestamp = .now
        return item
    }

    func update(
        title: String,
        score: Int,
        category: String,
        note: String,
        tags: [String],
        imageData: Data?,
        purchaseDate: Date?,
        price: Double?,
        recommendLevel: Int,
        isPinned: Bool
    ) {
        self.title = title
        self.score = score
        self.category = category
        self.note = note
        self.tags = tags
        self.imageData = imageData
        self.purchaseDate = purchaseDate
        self.price = price
        self.recommendLevel = recommendLevel
        self.isPinned = isPinned
        self.modifiedTimestamp = .now
    }
}

extension BestItemModel {
    static var sample: BestItemModel {
        let item = BestItemModel()
        item.title = "Sample Item"
        item.category = "Books"
        item.score = 4
        item.note = "Sample note"
        item.tags = ["tag1", "tag2"]
        return item
    }

    var gradient: LinearGradient {
        switch score {
        case 1, 2:
            return LinearGradient(
                colors: [Color.gray, Color.blue],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case 3:
            return LinearGradient(
                colors: [Color.gray, Color.gray],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case 4, 5:
            return LinearGradient(
                colors: [Color.accentColor, Color.accentColor],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        default:
            return LinearGradient(
                colors: [Color.gray, Color.blue],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

extension BestItemModel {
    var entity: BestItem {
        BestItem(model: self)
    }
}
