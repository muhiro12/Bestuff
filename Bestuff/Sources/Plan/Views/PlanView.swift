//
//  PlanView.swift
//  Bestuff
//
//  Created by Codex on 2025/07/30.
//

import SwiftUI

struct PlanView: View {
    let suggestion: String

    var body: some View {
        ScrollView {
            Text(suggestion)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
        .navigationTitle("Suggestion")
    }
}

#Preview(traits: .sampleData) {
    PlanView(suggestion: "Sample suggestion")
}
