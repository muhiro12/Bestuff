@testable import Bestuff
import Foundation
import SwiftData
import Testing

@MainActor
struct FilterLogicTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test func completion_score_label_filters_combine() throws {
        let labelA = TagService.create(context: context, name: "A")
        let labelB = TagService.create(context: context, name: "B")
        let a1 = StuffService.create(context: context, title: "A1", note: nil, occurredAt: .now, tags: [labelA])
        a1.update(score: 90, isCompleted: true)
        let b1 = StuffService.create(context: context, title: "B1", note: nil, occurredAt: .now, tags: [labelB])
        b1.update(score: 40, isCompleted: false)
        let a2 = StuffService.create(context: context, title: "A2", note: nil, occurredAt: .now, tags: [labelA])
        a2.update(score: 85, isCompleted: false)

        let all = try context.fetch(FetchDescriptor<Stuff>())
        #expect(all.count == 3)

        // Completion
        var filtered = all.filter(\.isCompleted)
        #expect(filtered.count == 1)

        // Score
        filtered = all.filter { $0.score >= 80 }
        #expect(filtered.count == 2)

        // Label
        filtered = all.filter { ($0.tags ?? []).contains { $0.name == "A" }}
        #expect(filtered.count == 2)

        // Combined: Label A and Score >= 80
        filtered = all.filter { ($0.tags ?? []).contains { $0.name == "A" }&& $0.score >= 80 }
        #expect(filtered.count == 2)

        // Combined: Pending and Score >= 80
        filtered = all.filter { $0.isCompleted == false && $0.score >= 80 }
        #expect(filtered.count == 1)
    }
}
