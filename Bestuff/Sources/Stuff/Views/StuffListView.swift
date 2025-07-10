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
    @Query(sort: \Stuff.occurredAt, order: .reverse)
    private var stuffs: [Stuff]
    @State private var searchText = ""
    @State private var isSettingsPresented = false

    var body: some View {
        ScrollViewReader { proxy in
            List(selection: $selection) {
                ForEach(filteredStuffs) { stuff in
                    NavigationLink(value: stuff) {
                        StuffRowView()
                            .environment(stuff)
                    }
                }
                .onDelete(perform: delete)
            }
            .overlay(alignment: .bottomTrailing) {
                ToTopButton {
                    guard let firstID = filteredStuffs.first?.id else {
                        return
                    }
                    withAnimation {
                        proxy.scrollTo(firstID, anchor: .top)
                    }
                }
                .padding()
            }
        }
        .searchable(text: $searchText)
        .navigationTitle(Text("Best Stuff"))
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                AddStuffButton()
            }

            ToolbarSpacer(.fixed, placement: .primaryAction)

            ToolbarItem(placement: .primaryAction) {
                Button("Settings", systemImage: "gearshape") {
                    Logger(#file).info("Settings button tapped")
                    isSettingsPresented = true
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
                Logger(#file).info("Deleting stuff \(String(describing: stuff.id))")
                try? DeleteStuffIntent.perform(stuff)
                Logger(#file).notice("Deleted stuff \(String(describing: stuff.id))")
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
