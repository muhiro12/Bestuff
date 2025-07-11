//
//  PlanNavigationView.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/07/11.
//

import SwiftData
import SwiftUI
import SwiftUtilities

struct PlanNavigationView: View {
    @State private var suggestions: [PlanPeriod: [String]] = [:]
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
