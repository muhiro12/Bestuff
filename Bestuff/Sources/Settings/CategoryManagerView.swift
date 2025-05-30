//
//  CategoryManagerView.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/04/21.
//

import SwiftUI
import SwiftData

struct CategoryManagerView: View {
    @Query private var allItems: [BestItemModel]
    @Environment(\.modelContext) private var modelContext

    var categories: [(name: String, count: Int)] {
        Dictionary(grouping: allItems.map { $0.category }, by: { $0 })
            .map { ($0.key, $0.value.count) }
            .sorted { $0.name < $1.name }
    }

    var body: some View {
        List {
            ForEach(categories, id: \.name) { entry in
                HStack {
                    Text(entry.name)
                    Spacer()
                    Text("\(entry.count)")
                        .foregroundColor(.secondary)
                }
                .swipeActions {
                    Button(role: .destructive) {
                        for item in allItems where item.category == entry.name {
                            item.update(
                                title: item.title,
                                score: item.score,
                                category: "General",
                                note: item.note,
                                tags: item.tags,
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
        .navigationTitle("Manage Categories")
    }
}
