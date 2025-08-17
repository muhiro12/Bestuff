//
//  StuffRow.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/07/08.
//

import SwiftData
import SwiftUI

struct StuffRow: View {
    @Environment(Stuff.self)
    private var stuff
    @Environment(\.modelContext)
    private var modelContext

    var body: some View {
        VStack(alignment: .leading) {
            Text(stuff.title)
                .font(.headline)
            if let note = stuff.note, !note.isEmpty {
                Text(note)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            if stuff.isCompleted {
                Label("Completed", systemImage: "checkmark.circle.fill")
                    .font(.footnote)
                    .foregroundStyle(.green)
            }
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button {
                markCompleted()
            } label: {
                Label("Complete", systemImage: "checkmark.circle")
            }
            .tint(.green)

            Button {
                applyFeedback(delta: 10)
            } label: {
                Label("Helpful", systemImage: "hand.thumbsup")
            }
            .tint(.blue)

            Button(role: .destructive) {
                applyFeedback(delta: -10)
            } label: {
                Label("Not helpful", systemImage: "hand.thumbsdown")
            }
        }
    }

    private func applyFeedback(delta: Int) {
        let newScore = max(0, min(100, stuff.score + delta))
        stuff.update(score: newScore, lastFeedback: delta.signum())
        modelContext.insert(stuff)
    }

    private func markCompleted() {
        if stuff.isCompleted {
            return
        }
        let bonus = 15
        let newScore = max(0, min(100, stuff.score + bonus))
        stuff.update(score: newScore, isCompleted: true)
        modelContext.insert(stuff)
    }
}

#Preview(traits: .sampleData) {
    let schema: Schema = .init([Stuff.self])
    let configuration: ModelConfiguration = .init(schema: schema, isStoredInMemoryOnly: true)
    let container: ModelContainer = try! .init(for: schema, configurations: [configuration])
    let context: ModelContext = .init(container)
    let sample = StuffService.create(
        context: context,
        title: String(localized: "Sample"),
        note: nil,
        occurredAt: .now,
        tags: []
    )
    return StuffRow()
        .environment(sample)
        .modelContainer(container)
}
