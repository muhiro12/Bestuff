//
//  PlanNavigationView.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/07/11.
//

import SwiftUI

struct PlanNavigationView: View {
    @State private var selection: PlanSelection?

    var body: some View {
        NavigationSplitView {
            PlanListView(selection: $selection)
        } detail: {
            if let selection {
                PlanView(selection: selection)
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
