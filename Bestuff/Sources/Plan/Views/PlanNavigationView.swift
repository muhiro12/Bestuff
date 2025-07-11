//
//  PlanNavigationView.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/07/11.
//

import SwiftUI

struct PlanNavigationView: View {
    @State private var selection: String?

    var body: some View {
        NavigationSplitView {
            PlanListView(selection: $selection)
        } detail: {
            if let suggestion = selection {
                PlanView(suggestion: suggestion)
            } else {
                Text("Select Suggestion")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview(traits: .sampleData) {
    PlanNavigationView()
}
