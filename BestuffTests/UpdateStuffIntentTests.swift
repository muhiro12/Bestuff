@testable import Bestuff
import Foundation
import SwiftData
import Testing

struct UpdateStuffIntentTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test func perform() throws {
        let model = try CreateStuffIntent.perform(
            (
                context: context,
                title: "Title",
                category: "General",
                note: nil,
                occurredAt: .now
            )
        )
        _ = try UpdateStuffIntent.perform(
            (
                model: model,
                title: "Updated",
                category: "General",
                note: "Note",
                occurredAt: .now
            )
        )
        let tag = try CreateTagIntent.perform((context: context, name: "Tag"))
        model.update(tags: [tag])
        #expect(model.title == "Updated")
        #expect(model.note == "Note")
        #expect(model.tags?.count == 1)
    }
}
