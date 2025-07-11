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
    private(set) var title: String
    private(set) var category: String
    private(set) var note: String?
    private(set) var score: Int
    private(set) var occurredAt: Date
    private(set) var createdAt: Date

    private init(
        title: String,
        category: String,
        note: String? = nil,
        score: Int = 0,
        occurredAt: Date = .now,
        createdAt: Date = .now
    ) {
        self.title = title
        self.category = category
        self.note = note
        self.score = score
        self.occurredAt = occurredAt
        self.createdAt = createdAt
    }

    static func create(
        title: String,
        category: String,
        note: String? = nil,
        score: Int = 0,
        occurredAt: Date = .now,
        createdAt: Date = .now
    ) -> Stuff {
        .init(
            title: title,
            category: category,
            note: note,
            score: score,
            occurredAt: occurredAt,
            createdAt: createdAt
        )
    }

    func update(
        title: String? = nil,
        category: String? = nil,
        note: String? = nil,
        score: Int? = nil,
        occurredAt: Date? = nil
    ) {
        if let title { self.title = title }
        if let category { self.category = category }
        if let note { self.note = note }
        if let score { self.score = score }
        if let occurredAt { self.occurredAt = occurredAt }
    }
}
