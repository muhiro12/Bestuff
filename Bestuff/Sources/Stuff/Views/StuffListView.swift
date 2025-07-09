//
//  StuffListView.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/07/08.
//

import SwiftData
import SwiftUI

struct StuffListView: View {
    @Binding var selection: Stuff?
    @Environment(\.modelContext)
    private var modelContext
    @Query(sort: \Stuff.createdAt, order: .reverse)
    private var stuffs: [Stuff]
    @State private var searchText = ""
    @State private var isSettingsPresented = false

    var body: some View {
        List(selection: $selection) {
            ForEach(filteredStuffs) { stuff in
                NavigationLink(value: stuff) {
                    StuffRowView()
                        .environment(stuff)
                }
            }
            .onDelete(perform: delete)
        }
        .searchable(text: $searchText)
        .navigationTitle(Text("Best Stuff"))
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                AddStuffButton()
                PredictStuffButton()
            }

            ToolbarSpacer(.fixed, placement: .primaryAction)

            ToolbarItem(placement: .primaryAction) {
                Button {
                    isSettingsPresented = true
                } label: {
                    Label("Settings", systemImage: "gearshape")
                }
            }
        }
        .sheet(isPresented: $isSettingsPresented) {
            SettingsView()
        }
    }

    private var filteredStuffs: [Stuff] {
        if searchText.isEmpty {
            stuffs
        } else {
            stuffs.filter { stuff in
                stuff.title.localizedCaseInsensitiveContains(searchText) ||
                    stuff.category.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    private func delete(at offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let stuff = stuffs[index]
                try? DeleteStuffIntent.perform(stuff)
            }
        }
    }
}

#Preview(traits: .sampleData) {
    NavigationSplitView {
        StuffListView(selection: .constant(nil))
    } detail: {
        Text("Detail")
    }
}
