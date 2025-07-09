//
//  BestuffTests.swift
//  BestuffTests
//
//  Created by Hiromu Nakano on 2025/07/08.
//

import Testing
@testable import Bestuff

struct BestuffTests {
    @Test func stuffInitialization() async throws {
        let stuff = Stuff(title: "Sample", category: "General", note: "Note", occurredAt: .now)
        #expect(stuff.title == "Sample")
        #expect(stuff.category == "General")
        #expect(stuff.note == "Note")
    }
}

