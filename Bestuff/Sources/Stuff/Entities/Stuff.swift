//
//  Stuff.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/07/08.
//

import Foundation
import SwiftData

@Model
nonisolated final class Stuff {
    var title: String
    var category: String
    var note: String?
    var occurredAt: Date
    var score: Int
    var createdAt: Date

    init(
        title: String,
        category: String,
        note: String? = nil,
        occurredAt: Date,
        score: Int = 0,
        createdAt: Date = .now
    ) {
        self.title = title
        self.category = category
        self.note = note
        self.occurredAt = occurredAt
        self.score = score
        self.createdAt = createdAt
    }
}
