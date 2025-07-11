//
//  ContentNavigationView.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/07/08.
//

import SwiftData
import SwiftUI

struct ContentNavigationView: View {
    @State private var selection: Stuff?
    @State private var searchText = ""

    var body: some View {
        NavigationSplitView {
            StuffListView(
                selection: $selection,
                searchText: $searchText
            )
        } detail: {
            if let stuff = selection {
                StuffView()
                    .environment(stuff)
            } else {
                Text("Select Stuff")
                    .foregroundStyle(.secondary)
            }
        }
        .searchable(text: $searchText)
    }
}

#Preview(traits: .sampleData) {
    ContentNavigationView()
}
