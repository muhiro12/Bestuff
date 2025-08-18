@testable import Bestuff
import Foundation
import SwiftData
import Testing

@MainActor
struct PinningTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test func toggle_pinned_updates_flag() throws {
        let model = StuffService.create(
            context: context,
            title: "Item",
            note: nil,
            occurredAt: .now,
            tags: []
        )
        #expect(model.isPinned == false)
        model.update(pinned: true)
        #expect(model.isPinned == true)
        model.update(pinned: false)
        #expect(model.isPinned == false)
    }
}
