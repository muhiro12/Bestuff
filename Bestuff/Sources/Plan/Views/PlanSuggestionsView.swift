//
//  PlanSuggestionsView.swift
//  Bestuff
//
//  Created by Codex on 2025/07/12.
//

import SwiftData
import SwiftUI
import SwiftUtilities

struct PlanSuggestionsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var suggestions: [PlanPeriod: [String]] = [:]
    private let periods: [PlanPeriod] = [.today, .thisWeek, .nextTrip]
    @State private var isProcessing = false
    @State private var selection: String?

    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                if suggestions.isEmpty {
                    Text("No suggestions yet")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(periods) { period in
                        if let actions = suggestions[period] {
                            Section(period.title) {
                                ForEach(actions, id: \.self) { suggestion in
                                    Text(suggestion)
                                        .lineLimit(1)
                                        .tag(suggestion)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(Text("Plan"))
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
            for period in periods {
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
    PlanSuggestionsView()
}
