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
    @State private var scrollToTopID = UUID()

    var body: some View {
        ScrollViewReader { proxy in
            List(selection: $selection) {
                Color.clear
                    .frame(height: 0)
                    .id(scrollToTopID)
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
                    withAnimation {
                        proxy.scrollTo(scrollToTopID, anchor: .top)
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
                Button {
                    Logger(#file).info("Settings button tapped")
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
