@testable import Bestuff
import SwiftData
import Testing

struct TagTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test func createAndFetch() throws {
        _ = try CreateTagIntent.perform((context: context, name: "Sample"))
        let fetched = try context.fetch(FetchDescriptor<Bestuff.Tag>())
        #expect(fetched.count == 1)
        #expect(fetched.first?.name == "Sample")
    }

    @Test func avoidDuplicates() throws {
        let first = try CreateTagIntent.perform((context: context, name: "Dup"))
        let second = try CreateTagIntent.perform((context: context, name: "Dup"))
        let fetched = try context.fetch(FetchDescriptor<Bestuff.Tag>())
        #expect(fetched.count == 1)
        #expect(first.id == second.id)
    }
}
