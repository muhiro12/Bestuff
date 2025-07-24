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

    var body: some View {
        VStack(alignment: .leading) {
            Text(stuff.title)
                .font(.headline)
            if let note = stuff.note, !note.isEmpty {
                Text(note)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
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
            note: nil,
            occurredAt: .now,
            tags: []
        )
    )
    return StuffRow()
        .environment(sample)
        .modelContainer(container)
}
