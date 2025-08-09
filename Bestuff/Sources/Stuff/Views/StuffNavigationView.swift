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
                    .id(stuff.id)
            } else {
                Text("Select Stuff")
                    .foregroundStyle(.secondary)
            }
        }
        .searchable(text: $searchText)
        .onChange(of: selection) { newValue, _ in
            Logger(#file).notice("Selection changed to \(String(describing: newValue?.id))")
        }
        .onAppear {
            Logger(#file).info("StuffNavigationView appeared")
        }
    }
}

#Preview(traits: .sampleData) {
    StuffNavigationView()
}
