//
//  PlanView.swift
//  Bestuff
//
//  Created by Codex on 2025/07/12.
//

import SwiftData
import SwiftUI

struct PlanView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var suggestions: [String] = []
    @State private var period: PlanPeriod = .nextMonth
    @State private var isProcessing = false
    @State private var selection: String?

    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                Picker("Period", selection: $period) {
                    ForEach(PlanPeriod.allCases) { period in
                        Text(period.title).tag(period)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.vertical)

                if suggestions.isEmpty {
                    Text("No suggestions yet")
                        .foregroundStyle(.secondary)
                } else {
                    Section("Suggestions") {
                        ForEach(suggestions, id: \.self) { suggestion in
                            NavigationLink(value: suggestion) {
                                Text(suggestion)
                                    .lineLimit(1)
                            }
                        }
                    }
                }
            }
            .navigationTitle(Text("Plan"))
            .toolbar {
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
                PlanDetailView(suggestion: suggestion)
            } else {
                Text("Select Suggestion")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationDestination(for: String.self) { suggestion in
            PlanDetailView(suggestion: suggestion)
        }
    }

    private func generate() {
        Logger(#file).info("Generating plan suggestions")
        isProcessing = true
        Task {
            let result = try? await PlanStuffIntent.perform(
                (context: modelContext, period: period)
            )
            suggestions = result?.actions ?? []
            isProcessing = false
            Logger(#file).notice("Generated suggestions count \(suggestions.count)")
        }
    }
}

#Preview(traits: .sampleData) {
    PlanView()
}
