@testable import Bestuff
import Foundation
import SwiftData
import Testing

@MainActor
struct TagDuplicateResolutionTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test func resolve_duplicates_reassigns_items_and_deletes_children() throws {
        // Create duplicate tags with same name/type
        let t1 = Bestuff.Tag.create(name: "Dup", type: .label)
        let t2 = Bestuff.Tag.create(name: "Dup", type: .label)
        context.insert(t1)
        context.insert(t2)
        let item = StuffService.create(context: context, title: "X", note: nil, occurredAt: .now, tags: [t2])
        #expect((item.tags ?? []).contains { $0 === t2 })

        try TagService.resolveDuplicates(context: context)

        // After resolving, only one tag named Dup remains
        let allTags = try context.fetch(FetchDescriptor<Bestuff.Tag>())
        let dups = allTags.filter { $0.name == "Dup" }
        #expect(dups.count == 1)

        // Item should reference the surviving tag
        let survivor = dups.first!
        #expect((item.tags ?? []).contains { $0 === survivor })
    }
}
