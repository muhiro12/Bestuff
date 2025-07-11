//
//  PlanNavigationView.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/07/11.
//

import SwiftUI

struct PlanNavigationView: View {
    @Environment(\.modelContext)
    private var modelContext
    @State private var suggestions: [PlanPeriod: [String]] = [:]
    @State private var selection: String?
    @State private var isProcessing = false

    var body: some View {
        NavigationSplitView {
            PlanListView(
                selection: $selection,
                suggestions: suggestions
            )
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    CloseButton()
                }
                ToolbarItem(placement: .confirmationAction) {
                    if isProcessing {
                        ProgressView()
                    } else {
                        Button("Generate", systemImage: "sparkles", action: generate)
                            .buttonStyle(.borderedProminent)
                            .tint(.accentColor)
                    }
                }
            }
        } detail: {
            if let suggestion = selection {
                PlanView(suggestion: suggestion)
            } else {
                Text("Select Suggestion")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func generate() {
        Logger(#file).info("Generating plan suggestions")
        isProcessing = true
        Task {
            var results: [PlanPeriod: [String]] = [:]
            for period in [PlanPeriod.today, .thisWeek, .nextTrip] {
                let result = try? await PlanStuffIntent.perform(
                    (context: modelContext, period: period)
                )
                results[period] = result?.actions ?? []
            }
            suggestions = results
            isProcessing = false
            Logger(#file).notice("Generated suggestions count \(suggestions.values.flatMap(\.self).count)")
        }
    }
}

#Preview(traits: .sampleData) {
    PlanNavigationView()
}
