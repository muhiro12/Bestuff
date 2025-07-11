//
//  PlanListView.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/07/11.
//

import SwiftUI
import SwiftUtilities

struct PlanListView: View {
    @Binding private var selection: String?
    let suggestions: [PlanPeriod: [String]]

    private let periods: [PlanPeriod] = [.today, .thisWeek, .nextTrip]

    init(selection: Binding<String?>, suggestions: [PlanPeriod: [String]]) {
        _selection = selection
        self.suggestions = suggestions
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
    }
}

#Preview(traits: .sampleData) {
    NavigationStack {
        PlanListView(
            selection: .constant(nil),
            suggestions: [:]
        )
    }
}
