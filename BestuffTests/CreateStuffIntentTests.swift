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
            (context: context, title: "Title", category: "General", note: nil)
        )
        let items = try context.fetch(FetchDescriptor<Stuff>())
        #expect(items.count == 1)
        #expect(items.first?.title == "Title")
    }
}
