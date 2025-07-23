//
//  StuffView.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/07/08.
//

import SwiftUI

struct StuffView: View {
    @Environment(Stuff.self)
    private var stuff

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let note = stuff.note {
                    Text(note)
                }
                Text("Score: \(stuff.score)")
                    .font(.headline)
                Text("Occurred \(stuff.occurredAt.formatted(.dateTime))")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Text("Created \(stuff.createdAt.formatted(.dateTime))")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(.thinMaterial)
            .clipShape(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
            .glassEffect()
            .padding()
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
