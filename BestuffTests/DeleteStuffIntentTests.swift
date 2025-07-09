@testable import Bestuff
import Foundation
import SwiftData
import Testing

@MainActor
struct DeleteStuffIntentTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test func perform() throws {
        let model = try CreateStuffIntent.perform(
            (context: context, title: "Title", category: "General", note: nil, occurredAt: .now)
        )
        #expect(try context.fetch(FetchDescriptor<Stuff>()).count == 1)
        try DeleteStuffIntent.perform(model)
        let stuffs = try context.fetch(FetchDescriptor<Stuff>())
        #expect(stuffs.isEmpty)
    }
}
