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
    var score: Int
    var createdAt: Date
    var occurredAt: Date

    init(
        title: String,
        category: String,
        note: String? = nil,
        score: Int = 0,
        createdAt: Date = .now,
        occurredAt: Date = .now
    ) {
        self.title = title
        self.category = category
        self.note = note
        self.score = score
        self.createdAt = createdAt
        self.occurredAt = occurredAt
    }
}
