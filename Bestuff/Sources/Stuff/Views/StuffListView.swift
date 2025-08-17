//
//  StuffListView.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/07/08.
//

import Foundation
import SwiftData
import SwiftUI

struct StuffListView: View {
    @Environment(\.modelContext)
    private var modelContext

    @Query(sort: \Stuff.occurredAt, order: .reverse)
    private var queriedStuffs: [Stuff]

    private let overrideStuffs: [Stuff]?

    @Binding private var selection: Stuff?
    @Binding private var searchText: String

    @State private var sort = StuffSort.occurredDateDescending
    @State private var isRecapPresented = false
    @State private var isPlanPresented = false
    @State private var isTagPresented = false
    @AppStorage(BoolAppStorageKey.isDebugOn)
    private var isDebugOn

    init(
        stuffs: [Stuff]? = nil,
        selection: Binding<Stuff?>,
        searchText: Binding<String>
    ) {
        overrideStuffs = stuffs
        _selection = selection
        _searchText = searchText
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
                            EditStuffButton()
                                .environment(stuff)
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
        .navigationTitle("Best Stuff")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                AddStuffButton()
            }
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Picker("Sort", selection: $sort) {
                        ForEach(StuffSort.allCases) { option in
                            Text(option.title).tag(option)
                        }
                    }
                } label: {
                    Label("Sort", systemImage: "arrow.up.arrow.down")
                }
            }
            ToolbarItem(placement: .secondaryAction) {
                Button("Recap", systemImage: "calendar") {
                    Logger(#file).info("Recap button tapped")
                    isRecapPresented = true
                }
                .buttonStyle(.bordered)
            }
            ToolbarItem(placement: .secondaryAction) {
                Button("Plan", systemImage: "lightbulb") {
                    Logger(#file).info("Plan button tapped")
                    isPlanPresented = true
                }
                .buttonStyle(.bordered)
            }
            ToolbarItem(placement: .secondaryAction) {
                Button("Tags", systemImage: "tag") {
                    Logger(#file).info("Tags button tapped")
                    isTagPresented = true
                }
                .buttonStyle(.bordered)
            }
            ToolbarItem(placement: .secondaryAction) {
                SettingsButton()
            }
            if isDebugOn {
                ToolbarItem(placement: .secondaryAction) {
                    DebugButton()
                }
            }
        }
        .sheet(isPresented: $isRecapPresented) {
            RecapNavigationView()
        }
        .sheet(isPresented: $isPlanPresented) {
            PlanNavigationView()
        }
        .sheet(isPresented: $isTagPresented) {
            TagNavigationView()
        }
    }

    private var filteredStuffs: [Stuff] {
        var result: [Stuff]
        if searchText.isEmpty {
            result = stuffs
        } else {
            result = stuffs.filter { model in
                model.title.localizedCaseInsensitiveContains(searchText) ||
                    (model.note?.localizedCaseInsensitiveContains(searchText) ?? false)
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
                StuffService.delete(model: stuff)
                Logger(#file).notice("Deleted stuff \(String(describing: stuff.id))")
            }
        }
    }

    private func delete(_ stuff: Stuff) {
        guard let index = stuffs.firstIndex(where: {
            $0.id == stuff.id
        }) else {
            return
        }
        delete(at: IndexSet(integer: index))
    }
}

#Preview(traits: .sampleData) {
    NavigationStack {
        StuffListView(
            selection: .constant(nil),
            searchText: .constant("")
        )
    }
}
