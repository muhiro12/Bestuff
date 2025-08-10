@testable import Bestuff
import Foundation
import SwiftData
import Testing

@MainActor
struct StuffServiceTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test func create_inserts_stuff_with_tag() throws {
        let tag = TagService.create(context: context, name: "Tag")
        _ = StuffService.create(
            context: context,
            title: "Title",
            note: nil,
            occurredAt: .now,
            tags: [tag]
        )
        let stuffs = try context.fetch(FetchDescriptor<Stuff>())
        #expect(stuffs.count == 1)
        #expect(stuffs.first?.tags?.count == 1)
    }

    @Test func delete_removes_stuff() throws {
        let model = StuffService.create(
            context: context,
            title: "Title",
            note: nil,
            occurredAt: .now,
            tags: []
        )
        #expect(try context.fetch(FetchDescriptor<Stuff>()).count == 1)
        StuffService.delete(model: model)
        let stuffs = try context.fetch(FetchDescriptor<Stuff>())
        #expect(stuffs.isEmpty)
    }

    @Test func update_modifies_properties() throws {
        let tag = TagService.create(context: context, name: "Tag")
        let model = StuffService.create(
            context: context,
            title: "Title",
            note: nil,
            occurredAt: .now,
            tags: []
        )
        _ = StuffService.update(
            model: model,
            title: "Updated",
            note: "Note",
            occurredAt: .now,
            tags: [tag]
        )
        #expect(model.title == "Updated")
        #expect(model.note == "Note")
        #expect(model.tags?.count == 1)
    }

    @Test func create_sets_initial_values() throws {
        let model = StuffService.create(
            context: context,
            title: "Sample",
            note: "Note",
            occurredAt: .now,
            tags: []
        )
        #expect(model.title == "Sample")
        #expect(model.note == "Note")
    }
}
