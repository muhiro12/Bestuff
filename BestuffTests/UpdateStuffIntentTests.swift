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
        let model = try CreateStuffIntent.perform(
            (
                context: context,
                title: "Old",
                category: "General",
                note: nil,
                occurredAt: .now
            )
        )
        _ = try UpdateStuffIntent.perform(
            (
                context: context,
                model: model,
                title: "New",
                category: "Updated",
                note: "Note",
                occurredAt: .now
            )
        )
        let fetched = try context.fetch(FetchDescriptor<Stuff>()).first
        #expect(fetched?.title == "New")
        #expect(fetched?.category == "Updated")
    }
}
