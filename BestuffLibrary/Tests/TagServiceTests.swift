@testable import BestuffLibrary
import SwiftData
import Testing

struct TagServiceTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test func create_stores_tag_with_name() throws {
        _ = TagService.create(context: context, name: "Sample")
        let fetched = try context.fetch(FetchDescriptor<BestuffLibrary.Tag>())
        #expect(fetched.count == 1)
        #expect(fetched.first?.name == "Sample")
    }

    @Test func create_avoids_duplicate_tags() throws {
        let first = TagService.create(context: context, name: "Dup")
        let second = TagService.create(context: context, name: "Dup")
        let fetched = try context.fetch(FetchDescriptor<BestuffLibrary.Tag>())
        #expect(fetched.count == 1)
        #expect(first.id == second.id)
    }
}
