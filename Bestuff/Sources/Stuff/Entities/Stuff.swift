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
    private(set) var note: String?
    private(set) var score: Int
    @Relationship(inverse: \Tag.stuffs)
    private(set) var tags: [Tag]?
    private(set) var occurredAt: Date
    private(set) var createdAt: Date

    private init(
        title: String,
        note: String? = nil,
        score: Int = 0,
        occurredAt: Date = .now,
        createdAt: Date = .now,
        tags: [Tag] = []
    ) {
        self.title = title
        self.note = note
        self.score = score
        self.occurredAt = occurredAt
        self.createdAt = createdAt
        self.tags = tags
    }

    static func create(
        title: String,
        note: String? = nil,
        score: Int = 0,
        occurredAt: Date = .now,
        createdAt: Date = .now,
        tags: [Tag] = []
    ) -> Stuff {
        .init(
            title: title,
            note: note,
            score: score,
            occurredAt: occurredAt,
            createdAt: createdAt,
            tags: tags
        )
    }

    func update(
        title: String? = nil,
        note: String? = nil,
        score: Int? = nil,
        occurredAt: Date? = nil,
        tags: [Tag]? = nil
    ) {
        if let title {
            self.title = title
        }
        if let note {
            self.note = note
        }
        if let score {
            self.score = score
        }
        if let occurredAt {
            self.occurredAt = occurredAt
        }
        if let tags {
            self.tags = tags
        }
    }
}
