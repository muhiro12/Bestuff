//
//  BestItem.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/04/21.
//

import SwiftUI
import SwiftData

@Model
final class BestItem {
    var timestamp: Date = Date.now
    var title: String = ""
    var score: Int = 0
    var category: String = "General"
    var note: String = ""
    var tags: [String] = []
    var imageData: Data? = nil
    var purchaseDate: Date? = nil
    var price: Double? = nil
    var recommendLevel: Int = 3
    var isPinned: Bool = false

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
    ) -> BestItem {
        let item = BestItem()
        item.timestamp = .now
        item.title = title
        item.score = score
        item.category = category
        item.note = note
        item.tags = tags
        item.imageData = imageData
        item.purchaseDate = purchaseDate
        item.price = price
        item.recommendLevel = recommendLevel
        context.insert(item)
        return item
    }
}

extension BestItem {
    static var sample: BestItem {
        let item = BestItem()
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
