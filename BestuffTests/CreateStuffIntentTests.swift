@testable import Bestuff
import SwiftData
import Testing

@MainActor
struct CreateStuffIntentTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test func perform() throws {
        let _ = try CreateStuffIntent.perform(
            (context: context, title: "Title", category: "General", note: nil, occurredAt: .now)
        )
        let stuffs = try context.fetch(FetchDescriptor<Stuff>())
        #expect(stuffs.count == 1)
        #expect(stuffs.first?.title == "Title")
    }
}
