//
//  StuffRowView.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/07/08.
//

import SwiftUI

struct StuffRowView: View {
    @Environment(Stuff.self)
    private var stuff

    var body: some View {
        VStack(alignment: .leading) {
            Text(stuff.title)
                .font(.headline)
            Text(stuff.category)
                .font(.subheadline)
            if let note = stuff.note, !note.isEmpty {
                Text(note)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview(traits: .sampleData) {
    StuffRowView()
        .environment(
            Stuff(
                title: "Sample",
                category: "General",
                occurredAt: .now,
                createdAt: .now
            )
        )
}
