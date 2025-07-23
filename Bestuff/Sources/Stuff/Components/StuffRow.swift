//
//  StuffRow.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/07/08.
//

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
    StuffRow()
        .environment(
            Stuff.create(
                title: "Sample",
                occurredAt: .now,
                createdAt: .now
            )
        )
}
