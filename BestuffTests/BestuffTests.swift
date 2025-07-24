//
//  BestuffTests.swift
//  BestuffTests
//
//  Created by Hiromu Nakano on 2025/07/08.
//

@testable import Bestuff
import Foundation
import SwiftData
import Testing

struct BestuffTests {
    let context: ModelContext

    init() {
        context = testContext
    }

    @Test func stuffInitialization() throws {
        let model = try CreateStuffIntent.perform(
            (
                context: context,
                title: "Sample",
                note: "Note",
                occurredAt: .now,
                tags: []
            )
        )
        #expect(model.title == "Sample")
        #expect(model.note == "Note")
    }
}
