@testable import Bestuff
import SwiftData
import Testing

struct TagTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test func createAndFetch() throws {
        let tag = Tag.create(name: "Sample")
        context.insert(tag)
        let fetched = try context.fetch(FetchDescriptor<Bestuff.Tag>())
        #expect(fetched.count == 1)
        #expect(fetched.first?.name == "Sample")
    }
}
