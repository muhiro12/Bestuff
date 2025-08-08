@testable import Bestuff
import Foundation
import SwiftData
import Testing

@MainActor
struct UpdateStuffIntentTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test func perform() throws {
        let tag = try CreateTagIntent.perform((context: context, name: "Tag"))
        let model = try CreateStuffIntent.perform(
            (
                context: context,
                title: "Title",
                note: nil,
                occurredAt: .now,
                tags: []
            )
        )
        _ = try UpdateStuffIntent.perform(
            (
                model: model,
                title: "Updated",
                note: "Note",
                occurredAt: .now,
                tags: [tag]
            )
        )
        #expect(model.title == "Updated")
        #expect(model.note == "Note")
        #expect(model.tags?.count == 1)
    }
}
