@testable import Bestuff
import Foundation
import SwiftData
import Testing

struct BackupServiceTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test func export_import_roundtrip_preserves_data() throws {
        let label = TagService.create(context: context, name: "Work")
        let stuff = StuffService.create(
            context: context,
            title: "Write report",
            note: "Q3 summary",
            occurredAt: .now,
            tags: [label]
        )
        stuff.update(score: 80, isCompleted: true, source: "test")

        let data = try BackupService.exportJSON(context: context)

        // New in-memory context
        let newContext = testContext
        try BackupService.importJSON(context: newContext, data: data, conflictStrategy: .skip)

        let fetchedStuff = try newContext.fetch(FetchDescriptor<Bestuff.Stuff>())
        let fetchedTags = try newContext.fetch(FetchDescriptor<Bestuff.Tag>())

        #expect(fetchedStuff.count == 1)
        #expect(fetchedStuff.first?.title == "Write report")
        #expect(fetchedStuff.first?.note == "Q3 summary")
        #expect(fetchedStuff.first?.score == 80)
        #expect(fetchedStuff.first?.isCompleted == true)
        #expect(fetchedStuff.first?.source == "test")
        #expect((fetchedStuff.first?.tags ?? []).contains { $0.name == "Work" })
        #expect(fetchedTags.contains { $0.name == "Work" })
    }

    @Test func import_skip_duplicates_keeps_existing() throws {
        let date = Date()
        _ = StuffService.create(
            context: context,
            title: "Plan trip",
            note: "",
            occurredAt: date,
            tags: []
        )
        let payload = BackupPayload(
            tags: [],
            stuffs: [
                .init(
                    title: "Plan trip",
                    note: "New note",
                    score: 10,
                    tags: [],
                    occurredAt: date,
                    createdAt: date,
                    isCompleted: false,
                    lastFeedback: nil,
                    source: nil
                )
            ]
        )
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(payload)
        try BackupService.importJSON(context: context, data: data, conflictStrategy: .skip)
        let fetched = try context.fetch(FetchDescriptor<Bestuff.Stuff>())
        #expect(fetched.count == 1)
        #expect(fetched.first?.note == "")
    }

    @Test func import_update_duplicates_overwrites_existing() throws {
        let date = Date()
        let model = StuffService.create(
            context: context,
            title: "Read book",
            note: "old",
            occurredAt: date,
            tags: []
        )
        let payload = BackupPayload(
            tags: [],
            stuffs: [
                .init(
                    title: "Read book",
                    note: "new",
                    score: 50,
                    tags: ["Leisure"],
                    occurredAt: date,
                    createdAt: date,
                    isCompleted: true,
                    lastFeedback: 1,
                    source: "import"
                )
            ]
        )
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(payload)
        try BackupService.importJSON(context: context, data: data, conflictStrategy: .update)

        #expect(model.note == "new")
        #expect(model.score == 50)
        #expect(model.isCompleted == true)
        #expect(model.lastFeedback == 1)
        #expect(model.source == "import")
        #expect(model.tags?.contains { $0.name == "Leisure" } == true)
    }
}
