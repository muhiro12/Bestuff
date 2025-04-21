//
//  TagManagerView.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/04/21.
//

import SwiftUI
import SwiftData

struct TagManagerView: View {
    @Query private var allItems: [BestItem]
    @Environment(\.modelContext) private var modelContext

    var tagCounts: [(tag: String, count: Int)] {
        Dictionary(grouping: allItems.flatMap { $0.tags }, by: { $0 })
            .map { ($0.key, $0.value.count) }
            .sorted { $0.count > $1.count }
    }

    var body: some View {
        List {
            ForEach(tagCounts, id: \.tag) { entry in
                HStack {
                    Text("#\(entry.tag)")
                    Spacer()
                    Text("\(entry.count)")
                        .foregroundColor(.secondary)
                }
                .swipeActions {
                    Button(role: .destructive) {
                        for item in allItems where item.tags.contains(entry.tag) {
                            item.tags.removeAll { $0 == entry.tag }
                        }
                        try? modelContext.save()
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
            }
        }
        .navigationTitle("Manage Tags")
    }
}
