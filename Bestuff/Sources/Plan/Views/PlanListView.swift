//
//  PlanListView.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/07/11.
//

import SwiftData
import SwiftUI
import SwiftUtilities

struct PlanListView: View {
    @Environment(\.modelContext)
    private var modelContext

    @Binding private var selection: String?

    @State private var suggestions: [PlanPeriod: [String]] = [:]
    @State private var isProcessing = false

    private let periods: [PlanPeriod] = [.today, .thisWeek, .nextTrip]

    init(selection: Binding<String?>) {
        _selection = selection
    }

    var body: some View {
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
    NavigationStack {
        PlanListView(selection: .constant(nil))
    }
}
