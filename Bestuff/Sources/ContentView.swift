//
//  ContentView.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/07/08.
//

import SwiftData
import SwiftUI

struct ContentView: View {
    @State private var selection: Stuff?
    @State private var searchText = ""

    var body: some View {
        TabView {
            Tab {
                NavigationSplitView {
                    StuffListView(selection: $selection)
                } detail: {
                    if let stuff = selection {
                        StuffDetailView()
                            .environment(stuff)
                    } else {
                        Text("Select Stuff")
                            .foregroundStyle(.secondary)
                    }
                }
                .navigationDestination(for: Stuff.self) { stuff in
                    StuffDetailView()
                        .environment(stuff)
                }
            } label: {
                Label("Stuffs", systemImage: "list.bullet")
            }

            Tab {
                NavigationSplitView {
                    EmptyView()
                } detail: {
                    RecapView()
                }
            } label: {
                Label("Recap", systemImage: "calendar")
            }

            Tab {
                NavigationSplitView {
                    EmptyView()
                } detail: {
                    PlanView()
                }
            } label: {
                Label("Plan", systemImage: "lightbulb")
            }

            Tab(role: .search) {
                NavigationSplitView {
                    StuffListView(selection: $selection)
                } detail: {
                    if let stuff = selection {
                        StuffDetailView()
                            .environment(stuff)
                    } else {
                        Text("Select Stuff")
                            .foregroundStyle(.secondary)
                    }
                }
                .navigationDestination(for: Stuff.self) { stuff in
                    StuffDetailView()
                        .environment(stuff)
                }
            } label: {
                Label("Search", systemImage: "magnifyingglass")
            }
        }
        .searchable(text: $searchText)
    }
}

#Preview(traits: .sampleData) {
    ContentView()
}
