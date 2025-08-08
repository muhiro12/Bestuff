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

    var body: some View {
        List {
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
    }
}

#Preview(traits: .sampleData) {
    let schema: Schema = .init([Stuff.self])
    let configuration: ModelConfiguration = .init(schema: schema, isStoredInMemoryOnly: true)
    let container: ModelContainer = try! .init(for: schema, configurations: [configuration])
    let context: ModelContext = .init(container)
    let sample = try! CreateStuffIntent.perform(
        (
            context: context,
            title: String(localized: "Sample"),
            note: String(localized: "Notes"),
            occurredAt: .now,
            tags: []
        )
    )
    return NavigationStack {
        StuffView()
            .environment(sample)
    }
    .modelContainer(container)
}
