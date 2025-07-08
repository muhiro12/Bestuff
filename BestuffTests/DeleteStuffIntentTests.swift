@testable import Bestuff
import SwiftData
import Testing

@MainActor
struct DeleteStuffIntentTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test func perform() throws {
        let entity = try CreateStuffIntent.perform(
            (context: context, title: "Title", category: "General", note: nil)
        )
        #expect(try context.fetch(FetchDescriptor<Stuff>()).count == 1)
        try DeleteStuffIntent.perform((context: context, item: entity))
        let items = try context.fetch(FetchDescriptor<Stuff>())
        #expect(items.isEmpty)
    }
}
