//
//  BestuffTests.swift
//  BestuffTests
//
//  Created by Hiromu Nakano on 2025/07/08.
//

@testable import Bestuff
import Foundation
import Testing

struct BestuffTests {
    @Test func stuffInitialization() throws {
        let stuff = Stuff.create(title: "Sample", category: "General", note: "Note", occurredAt: .now)
        #expect(stuff.title == "Sample")
        #expect(stuff.category == "General")
        #expect(stuff.note == "Note")
    }
}
