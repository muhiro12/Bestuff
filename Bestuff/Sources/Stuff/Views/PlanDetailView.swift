//
//  PlanDetailView.swift
//  Bestuff
//
//  Created by Codex on 2025/07/30.
//

import SwiftUI

struct PlanDetailView: View {
    let suggestion: String

    var body: some View {
        ScrollView {
            Text(suggestion)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
        .navigationTitle(Text("Suggestion"))
    }
}

#Preview(traits: .sampleData) {
    PlanDetailView(suggestion: "Sample suggestion")
}
