//
//  StuffListView.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/07/08.
//

import Foundation
import SwiftData
import SwiftUI
import SwiftUtilities

struct StuffListView: View {
    @Environment(\.modelContext)
    private var modelContext

    @Query(sort: \Stuff.occurredAt, order: .reverse)
    private var queriedStuffs: [Stuff]

    private let overrideStuffs: [Stuff]?

    @Binding private var selection: Stuff?
    @Binding private var searchText: String

    @Binding private var sort: StuffSort

    init(
        stuffs: [Stuff]? = nil,
        selection: Binding<Stuff?>,
        searchText: Binding<String>,
        sort: Binding<StuffSort>
    ) {
        overrideStuffs = stuffs
        _selection = selection
        _searchText = searchText
        _sort = sort
    }

    private var stuffs: [Stuff] {
        overrideStuffs ?? queriedStuffs
    }

    var body: some View {
        List(selection: $selection) {
            ForEach(filteredStuffs) { stuff in
                StuffRow()
                    .environment(stuff)
                    .tag(stuff)
                    .contextMenu(
                        menuItems: {
                            StuffFormButton(
                                stuff: stuff,
                                title: "Edit",
                                systemImage: "pencil"
                            )
                            Button(
                                role: .destructive,
                                action: { delete(stuff) }
                            ) {
                                Label("Delete", systemImage: "trash")
                            }
                        },
                        preview: {
                            StuffView()
                                .environment(stuff)
                        }
                    )
            }
            .onDelete(perform: delete)
        }
        .navigationTitle(Text("Best Stuff"))
    }

    private var filteredStuffs: [Stuff] {
        var result: [Stuff]
        if searchText.isEmpty {
            result = stuffs
        } else {
            result = stuffs.filter { model in
                model.title.localizedCaseInsensitiveContains(searchText) ||
                    model.category.localizedCaseInsensitiveContains(searchText)
            }
        }
        return result.sorted { first, second in
            sort.areInIncreasingOrder(first, second)
        }
    }

    private func delete(at offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let stuff = stuffs[index]
                Logger(#file).info("Deleting stuff \(String(describing: stuff.id))")
                try? DeleteStuffIntent.perform(stuff)
                Logger(#file).notice("Deleted stuff \(String(describing: stuff.id))")
            }
        }
    }

    private func delete(_ stuff: Stuff) {
        guard let index = stuffs.firstIndex(where: { $0.id == stuff.id }) else { return }
        delete(at: IndexSet(integer: index))
    }
}

#Preview(traits: .sampleData) {
    NavigationStack {
        StuffListView(
            selection: .constant(nil),
            searchText: .constant(""),
            sort: .constant(.occurredDateDescending)
        )
    }
}
