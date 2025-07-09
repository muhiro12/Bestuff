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

    var body: some View {
        TabView {
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
            .tabItem { Label("Stuffs", systemImage: "list.bullet") }

            NavigationStack {
                RecapView()
            }
            .tabItem { Label("Recap", systemImage: "calendar") }
        }
    }
}

#Preview(traits: .sampleData) {
    ContentView()
}
