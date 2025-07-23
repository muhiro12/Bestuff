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
        let tag = try CreateTagIntent.perform((context: context, name: "Tag"))
        let model = try CreateStuffIntent.perform(
            (
                context: context,
                title: "Title",
                note: nil,
                occurredAt: .now,
                tags: [tag]
            )
        )
        let stuffs = try context.fetch(FetchDescriptor<Stuff>())
        #expect(stuffs.count == 1)
        #expect(stuffs.first?.tags?.count == 1)
    }
}
