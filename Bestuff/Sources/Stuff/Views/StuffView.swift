//
//  StuffView.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/07/08.
//

import SwiftData
import SwiftUI

struct StuffView: View {
    @Environment(Stuff.self)
    private var stuff
    @Environment(\.modelContext)
    private var modelContext

    var body: some View {
        Form {
            Section("Feedback") {
                HStack(spacing: 12) {
                    Button {
                        applyFeedback(delta: 10)
                    } label: {
                        Label("Helpful", systemImage: "hand.thumbsup")
                    }
                    .buttonStyle(.bordered)

                    Button {
                        applyFeedback(delta: -10)
                    } label: {
                        Label("Not helpful", systemImage: "hand.thumbsdown")
                    }
                    .buttonStyle(.bordered)

                    Button {
                        markCompleted()
                    } label: {
                        Label(stuff.isCompleted ? "Completed" : "Mark Complete", systemImage: "checkmark.circle")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(stuff.isCompleted ? .green : .accentColor)
                }
            }
            if let note = stuff.note {
                Section("Note") {
                    Text(note)
                }
            }
            Section("Score") {
                Text("\(stuff.score)")
                    .font(.headline)
            }
            Section("Occurred") {
                Text(stuff.occurredAt.formatted(.dateTime))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Section("Created") {
                Text(stuff.createdAt.formatted(.dateTime))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(stuff.title)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                ShareLink(
                    item: [
                        stuff.title,
                        "Score: \(stuff.score)",
                        stuff.note
                    ].compactMap(\.self).joined(separator: "\n")
                )
            }
            ToolbarItem(placement: .primaryAction) {
                EditStuffButton()
                    .environment(stuff)
            }
        }
        .onAppear {
            Logger(#file).info("StuffView appeared for id \(String(describing: stuff.id))")
        }
    }

    private func applyFeedback(delta: Int) {
        let newScore = max(0, min(100, stuff.score + delta))
        stuff.update(score: newScore, lastFeedback: delta.signum())
        modelContext.insert(stuff)
    }

    private func markCompleted() {
        guard !stuff.isCompleted else { return }
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
      let sample = try! StuffService.create(
          context: context,
          title: String(localized: "Sample"),
          note: String(localized: "Notes"),
          occurredAt: .now,
          tags: []
      )
    return NavigationStack {
        StuffView()
            .environment(sample)
    }
    .modelContainer(container)
}
