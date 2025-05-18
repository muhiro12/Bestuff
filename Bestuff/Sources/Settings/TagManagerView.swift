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
                            let newTags = item.tags.filter { $0 != entry.tag }
                            item.update(
                                title: item.title,
                                score: item.score,
                                category: item.category,
                                note: item.note,
                                tags: newTags,
                                imageData: item.imageData,
                                purchaseDate: item.purchaseDate,
                                price: item.price,
                                recommendLevel: item.recommendLevel,
                                isPinned: item.isPinned
                            )
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
