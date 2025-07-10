//
//  StuffListView.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/07/08.
//

import SwiftData
import SwiftUI
import Foundation

struct StuffListView: View {
    @Binding var selection: Stuff?
    @Environment(\.modelContext)
    private var modelContext
    @Query(sort: \Stuff.occurredAt, order: .reverse)
    private var stuffs: [Stuff]
    @State private var searchText = ""
    @State private var sort: StuffSort = .occurredDateDescending
    @State private var isRecapPresented = false
    @State private var isPlanPresented = false
    @State private var isSettingsPresented = false
    @State private var editingStuff: Stuff?

    var body: some View {
        ScrollViewReader { proxy in
            List(selection: $selection) {
                ForEach(filteredStuffs) { stuff in
                    NavigationLink(value: stuff) {
                        StuffRowView()
                            .environment(stuff)
                    }
                    .contextMenu {
                        Button("Edit", systemImage: "pencil") {
                            editingStuff = stuff
                        }
                        Button(role: .destructive, action: { delete(stuff) }) {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
                .onDelete(perform: delete)
            }
        }
        .navigationTitle(Text("Best Stuff"))
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                HStack {
                    TextField("Filter", text: $searchText)
                        .textFieldStyle(.roundedBorder)
                    Spacer()
                    AddStuffButton()
                }
            }
            ToolbarItemGroup(placement: .secondaryAction) {
                Menu {
                    Picker("Sort", selection: $sort) {
                        ForEach(StuffSort.allCases) { option in
                            Text(option.title).tag(option)
                        }
                    }
                } label: {
                    Label("Sort", systemImage: "arrow.up.arrow.down")
                }
                Button("Recap", systemImage: "calendar") {
                    Logger(#file).info("Recap button tapped")
                    isRecapPresented = true
                }
                .buttonStyle(.bordered)
                Button("Plan", systemImage: "lightbulb") {
                    Logger(#file).info("Plan button tapped")
                    isPlanPresented = true
                }
                .buttonStyle(.bordered)
                Button("Settings", systemImage: "gearshape") {
                    Logger(#file).info("Settings button tapped")
                    isSettingsPresented = true
                }
            }
        }
        .sheet(isPresented: $isRecapPresented) {
            RecapTabView()
        }
        .sheet(isPresented: $isPlanPresented) {
            PlanTabView()
        }
        .sheet(isPresented: $isSettingsPresented) {
            SettingsView()
        }
        .sheet(item: $editingStuff) { stuff in
            StuffFormView(stuff: stuff)
        }
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
    NavigationSplitView {
        StuffListView(selection: .constant(nil))
    } detail: {
        Text("Detail")
    }
}
