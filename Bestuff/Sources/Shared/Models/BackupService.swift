//
//  BackupService.swift
//  Bestuff
//
//  Created by Codex on 2025/08/17.
//

import Foundation
import SwiftData

enum BackupConflictStrategy: String, CaseIterable, Sendable {
    case skip
    case update
}

struct BackupPayload: Codable, Sendable {
    var tags: [TagDump]
    var stuffs: [StuffDump]
}

struct TagDump: Codable, Sendable, Hashable {
    var name: String
    var typeID: String
}

struct StuffDump: Codable, Sendable, Hashable {
    var title: String
    var note: String?
    var score: Int
    var tags: [String]
    var occurredAt: Date
    var createdAt: Date
    var isCompleted: Bool
    var lastFeedback: Int?
    var source: String?
}

@MainActor
enum BackupService {
    static func exportJSON(context: ModelContext) throws -> Data {
        let allTags: [Tag] = try context.fetch(FetchDescriptor<Tag>())
        let allStuffs: [Stuff] = try context.fetch(FetchDescriptor<Stuff>())
        let tagDumps = allTags.map { tag in
            TagDump(name: tag.name, typeID: tag.typeID)
        }
        let stuffDumps = allStuffs.map { stuff in
            StuffDump(
                title: stuff.title,
                note: stuff.note,
                score: stuff.score,
                tags: (stuff.tags ?? []).map(\.name),
                occurredAt: stuff.occurredAt,
                createdAt: stuff.createdAt,
                isCompleted: stuff.isCompleted,
                lastFeedback: stuff.lastFeedback,
                source: stuff.source
            )
        }
        let payload = BackupPayload(tags: tagDumps, stuffs: stuffDumps)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(payload)
    }

    static func importJSON(
        context: ModelContext,
        data: Data,
        conflictStrategy: BackupConflictStrategy
    ) throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let payload = try decoder.decode(BackupPayload.self, from: data)

        // Restore tags first
        for dump in payload.tags {
            if (try? Tag.fetch(byName: dump.name, type: TagType(rawValue: dump.typeID) ?? .label, in: context)) != nil {
                continue
            }
            let type = TagType(rawValue: dump.typeID) ?? .label
            let tag = Tag.create(name: dump.name, type: type)
            context.insert(tag)
        }

        // Helper to resolve label models (labels only in stuffs)
        func labels(for names: [String]) -> [Tag] {
            var models: [Tag] = []
            for name in names {
                let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { continue }
                models.append(Tag.findOrCreate(name: trimmed, in: context, type: .label))
            }
            return models
        }

        // Date equality tolerance to account for ISO8601 precision
        func isSame(_ lhs: Date, _ rhs: Date) -> Bool {
            abs(lhs.timeIntervalSince(rhs)) < 1.0
        }

        // Restore stuffs
        for dump in payload.stuffs {
            // Define a simple identity: title + occurredAt
            let existing: Stuff? = try context.fetch(FetchDescriptor<Stuff>())
                .first { $0.title == dump.title && isSame($0.occurredAt, dump.occurredAt) }
            switch (existing, conflictStrategy) {
            case (.some, .skip):
                // Keep the existing one
                continue
            case (.some(let model), .update):
                model.update(
                    note: dump.note,
                    score: dump.score,
                    occurredAt: dump.occurredAt,
                    tags: labels(for: dump.tags),
                    isCompleted: dump.isCompleted,
                    lastFeedback: dump.lastFeedback,
                    source: dump.source
                )
            case (nil, _):
                let model = Stuff.create(
                    title: dump.title,
                    note: dump.note,
                    score: dump.score,
                    occurredAt: dump.occurredAt,
                    createdAt: dump.createdAt,
                    tags: labels(for: dump.tags),
                    isCompleted: dump.isCompleted,
                    lastFeedback: dump.lastFeedback,
                    source: dump.source
                )
                context.insert(model)
            }
        }
    }
}
