//
//  StuffListView.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/07/08.
//

import SwiftData
import SwiftUI

struct StuffListView: View {
    @Environment(\.modelContext)
    private var modelContext
    @Query(sort: \Stuff.createdAt, order: .reverse)
    private var stuffs: [Stuff]
    @State private var searchText = ""
    @State private var isSettingsPresented = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredStuffs) { stuff in
                    NavigationLink(value: stuff) {
                        StuffRowView()
                            .environment(stuff)
                    }
                }
                .onDelete(perform: delete)
            }
            .searchable(text: $searchText)
            .navigationDestination(for: Stuff.self) { stuff in
                StuffDetailView()
                    .environment(stuff)
            }
            .navigationTitle(Text("Best Stuff"))
            .toolbar {
                AddStuffButton()
                Button {
                    isSettingsPresented = true
                } label: {
                    Label("Settings", systemImage: "gearshape")
                }
            }
            .sheet(isPresented: $isSettingsPresented) {
                SettingsView()
            }
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

#Preview {
    StuffListView()
        .modelContainer(for: Stuff.self, inMemory: true)
}
