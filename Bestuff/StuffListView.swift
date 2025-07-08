//
//  StuffListView.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/07/08.
//

import SwiftData
import SwiftUI

struct StuffListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Stuff.createdAt, order: .reverse) private var items: [Stuff]
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredItems) { item in
                    NavigationLink(value: item) {
                        StuffRowView(stuff: item)
                    }
                }
                .onDelete(perform: delete)
            }
            .searchable(text: $searchText)
            .navigationDestination(for: Stuff.self) { item in
                StuffDetailView(stuff: item)
            }
            .navigationTitle(Text("Best Stuff"))
            .toolbar {
                AddStuffButton()
            }
        }
    }

    private var filteredItems: [Stuff] {
        if searchText.isEmpty {
            items
        } else {
            items.filter { stuff in
                stuff.title.localizedCaseInsensitiveContains(searchText) ||
                    stuff.category.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let item = items[index]
                if let entity = StuffEntity(item) {
                    try? DeleteStuffIntent.perform((context: modelContext, item: entity))
                }
            }
        }
    }
}

#Preview {
    StuffListView()
        .modelContainer(for: Stuff.self, inMemory: true)
}

