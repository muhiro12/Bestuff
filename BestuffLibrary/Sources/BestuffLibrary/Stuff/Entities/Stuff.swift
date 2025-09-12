//
//  Stuff.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/07/08.
//

import Foundation
import SwiftData

@Model
public final class Stuff {
    public private(set) var title: String
    public private(set) var note: String?
    public private(set) var score: Int
    @Relationship(inverse: \Tag.stuffs)
    public private(set) var tags: [Tag]?
    public private(set) var occurredAt: Date
    public private(set) var createdAt: Date
    public private(set) var isCompleted: Bool
    public private(set) var lastFeedback: Int?
    public private(set) var source: String?
    public private(set) var isPinned: Bool

    private init(
        title: String,
        note: String? = nil,
        score: Int = 0,
        occurredAt: Date = .now,
        createdAt: Date = .now,
        tags: [Tag] = [],
        isCompleted: Bool = false,
        lastFeedback: Int? = nil,
        source: String? = nil,
        isPinned: Bool = false
    ) {
        self.title = title
        self.note = note
        self.score = score
        self.occurredAt = occurredAt
        self.createdAt = createdAt
        self.tags = tags
        self.isCompleted = isCompleted
        self.lastFeedback = lastFeedback
        self.source = source
        self.isPinned = isPinned
    }

    public static func create(
        title: String,
        note: String? = nil,
        score: Int = 0,
        occurredAt: Date = .now,
        createdAt: Date = .now,
        tags: [Tag] = [],
        isCompleted: Bool = false,
        lastFeedback: Int? = nil,
        source: String? = nil,
        isPinned: Bool = false
    ) -> Stuff {
        .init(
            title: title,
            note: note,
            score: score,
            occurredAt: occurredAt,
            createdAt: createdAt,
            tags: tags,
            isCompleted: isCompleted,
            lastFeedback: lastFeedback,
            source: source,
            isPinned: isPinned
        )
    }

    public func update(
        title: String? = nil,
        note: String? = nil,
        score: Int? = nil,
        occurredAt: Date? = nil,
        tags: [Tag]? = nil,
        isCompleted: Bool? = nil,
        lastFeedback: Int? = nil,
        source: String? = nil,
        pinned: Bool? = nil
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
        if let isCompleted {
            self.isCompleted = isCompleted
        }
        if let lastFeedback {
            self.lastFeedback = lastFeedback
        }
        if let source {
            self.source = source
        }
        if let pinned {
            self.isPinned = pinned
        }
    }
}

// MARK: - Deletion helper
extension Stuff {
    public func delete() {
        if let context = self.modelContext {
            context.delete(self)
        }
    }
}
