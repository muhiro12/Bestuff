@testable import Bestuff
import Foundation
import SwiftData
import Testing

struct CreateStuffIntentTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test func perform() throws {
        _ = try CreateStuffIntent.perform(
            (
                context: context,
                title: "Title",
                category: "General",
                note: nil,
                occurredAt: .now
            )
        )
        let stuffs = try context.fetch(FetchDescriptor<Stuff>())
        #expect(stuffs.count == 1)
        #expect(stuffs.first?.title == "Title")
    }
}
