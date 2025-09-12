@testable import BestuffLibrary
import Foundation
import SwiftData
import Testing

struct BackupServiceDetailedTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test func detailed_counts_on_create_and_tag_duplicates() throws {
        let payload = BackupPayload(
            tags: [
                .init(name: "Work", typeID: TagType.label.rawValue),
                .init(name: "Work", typeID: TagType.label.rawValue),
                .init(name: "Leisure", typeID: TagType.label.rawValue)
            ],
            stuffs: [
                .init(
                    title: "New A",
                    note: nil,
                    score: 10,
                    tags: ["Work"],
                    occurredAt: .now,
                    createdAt: .now,
                    isCompleted: false,
                    lastFeedback: nil,
                    source: nil
                )
            ]
        )
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(payload)
        let result = try BackupService.importJSONDetailed(context: context, data: data, conflictStrategy: .update)
        #expect(result.tagCreated == 2) // Work, Leisure
        #expect(result.tagSkipped == 1) // duplicate Work
        #expect(result.stuffCreated == 1)
        #expect(result.stuffUpdated == 0)
        #expect(result.stuffSkipped == 0)
    }

    @Test func detailed_counts_on_update_and_skip() throws {
        let date = Date()
        _ = StuffService.create(context: context, title: "Same", note: "old", occurredAt: date, tags: [])

        // Update path
        var payload = BackupPayload(
            tags: [],
            stuffs: [
                .init(
                    title: "Same",
                    note: "new",
                    score: 20,
                    tags: [],
                    occurredAt: date,
                    createdAt: date,
                    isCompleted: true,
                    lastFeedback: 1,
                    source: "import"
                )
            ]
        )
        var encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        var data = try encoder.encode(payload)
        var result = try BackupService.importJSONDetailed(context: context, data: data, conflictStrategy: .update)
        #expect(result.stuffUpdated == 1)
        #expect(result.stuffCreated == 0)

        // Skip path
        payload = BackupPayload(tags: [], stuffs: payload.stuffs)
        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        data = try encoder.encode(payload)
        result = try BackupService.importJSONDetailed(context: context, data: data, conflictStrategy: .skip)
        #expect(result.stuffSkipped == 1)
        #expect(result.stuffCreated == 0)
    }
}
