//
//  PlanListView.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/07/11.
//

import SwiftUI

struct PlanListView: View {
    @Environment(\.modelContext)
    private var modelContext

    @Binding private var selection: PlanSelection?

    @State private var suggestions: [PlanPeriod: [PlanItem]] = [:]
    @State private var isProcessing = false

    private let periods: [PlanPeriod] = [.today, .thisWeek, .nextTrip]

    init(selection: Binding<PlanSelection?> = .constant(nil)) {
        _selection = selection
    }

    var body: some View {
        List(selection: $selection) {
            if suggestions.isEmpty {
                Text("No suggestions yet")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(periods) { period in
                    if let items = suggestions[period] {
                        Section(period.title) {
                            ForEach(items, id: \.self) { item in
                                HStack(spacing: 8) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(item.title)
                                            .font(.body)
                                            .lineLimit(1)
                                        Text(item.rationale)
                                            .font(.footnote)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(1)
                                    }
                                    Spacer(minLength: 8)
                                    Label("\(item.estimatedMinutes)", systemImage: "clock")
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                    Text("P\(item.priority)")
                                        .font(.footnote)
                                        .foregroundStyle(.secondary)
                                }
                                .tag(PlanSelection(period: period, item: item))
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Plan")
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
}

private extension PlanListView {
    func generate() {
        Logger(#file).info("Generating plan suggestions")
        isProcessing = true
        Task {
            var results: [PlanPeriod: [PlanItem]] = [:]
            for period in [PlanPeriod.today, .thisWeek, .nextTrip] {
                let result = try? await PlanStuffIntent.perform(
                    (context: modelContext, period: period)
                )
                results[period] = result?.items ?? []
            }
            suggestions = results
            isProcessing = false
            Logger(#file).notice("Generated suggestions count \(suggestions.values.flatMap(\.self).count)")
        }
    }
}

#Preview(traits: .sampleData) {
    NavigationStack {
        PlanListView()
    }
}
