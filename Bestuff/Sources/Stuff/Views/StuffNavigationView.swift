//
//  StuffNavigationView.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/07/11.
//

import SwiftUI

struct StuffNavigationView: View {
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
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            ShareLink(
                                item: [
                                    stuff.title,
                                    stuff.category,
                                    "Score: \(stuff.score)",
                                    stuff.note
                                ].compactMap(\.self).joined(separator: "\n")
                            )
                        }
                        ToolbarItem(placement: .primaryAction) {
                            EditStuffButton()
                                .environment(stuff)
                        }
                    }
            } else {
                Text("Select Stuff")
                    .foregroundStyle(.secondary)
            }
        }
        .searchable(text: $searchText)
    }
}

#Preview(traits: .sampleData) {
    StuffNavigationView()
}
