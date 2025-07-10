//
//  StuffDetailView.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/07/08.
//

import SwiftUI

struct StuffDetailView: View {
    @Environment(Stuff.self)
    private var stuff
    @State private var isEditing = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(stuff.title)
                    .font(.largeTitle.bold())
                Text(stuff.category)
                    .font(.title3)
                    .foregroundStyle(.secondary)
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
                Capsule(style: .continuous)
            )
            .glassEffect()
            .padding()
        }
        .navigationTitle(Text(stuff.title))
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                ShareLink(item: description)
            }

            ToolbarSpacer(.fixed, placement: .primaryAction)

            ToolbarItem(placement: .primaryAction) {
                Button("Edit", systemImage: "pencil") { isEditing = true }
                    .buttonStyle(.borderedProminent)
            }
        }
        .sheet(isPresented: $isEditing) {
            StuffFormView(stuff: stuff)
        }
    }

    private var description: String {
        [
            stuff.title,
            stuff.category,
            "Score: \(stuff.score)",
            stuff.note
        ].compactMap(\.self).joined(separator: "\n")
    }
}

#Preview(traits: .sampleData) {
    NavigationStack {
        StuffDetailView()
            .environment(
                Stuff(
                    title: "Sample",
                    category: "General",
                    note: "Notes",
                    score: 80,
                    occurredAt: .now,
                    createdAt: .now
                )
            )
    }
}
