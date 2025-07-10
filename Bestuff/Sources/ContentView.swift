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
        NavigationSplitView {
            StuffListView(selection: $selection)
        } detail: {
            if let stuff = selection {
                StuffView()
                    .environment(stuff)
            } else {
                Text("Select Stuff")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationDestination(for: Stuff.self) { stuff in
            StuffView()
                .environment(stuff)
        }
    }
}

#Preview(traits: .sampleData) {
    ContentView()
}
