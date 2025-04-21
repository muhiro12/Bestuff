//
//  CategoryManagerView.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/04/21.
//

import SwiftUI
import SwiftData

struct CategoryManagerView: View {
    @Query private var allItems: [BestItem]
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
                            item.category = "General"
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
