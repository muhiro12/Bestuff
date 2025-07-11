//
//  RecapNavigationView.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/07/11.
//

import SwiftData
import SwiftUI

struct RecapNavigationView: View {
    @Query(sort: \Stuff.occurredAt, order: .reverse)
    private var stuffs: [Stuff]

    @State private var selection: Date?
    @State private var stuffSelection: Stuff?
    @State private var period: RecapPeriod = .monthly
    @State private var searchText = ""

    var body: some View {
        NavigationSplitView {
            RecapListView(
                selection: $selection,
                period: $period
            )
        } content: {
            if let date = selection {
                StuffListView(
                    stuffs: groupedStuffs[date] ?? [],
                    selection: $stuffSelection,
                    searchText: $searchText
                )
                .navigationTitle(Text(title(for: date)))
            } else {
                Text("Select Period")
                    .foregroundStyle(.secondary)
            }
        } detail: {
            if let stuff = stuffSelection {
                StuffView()
                    .environment(stuff)
            } else {
                Text("Select Stuff")
                    .foregroundStyle(.secondary)
            }
        }
        .onDisappear {
            selection = nil
            stuffSelection = nil
        }
        .onChange(of: selection) { _, newValue in
            if newValue == nil {
                stuffSelection = nil
            }
        }
    }

    private var groupedStuffs: [Date: [Stuff]] {
        Dictionary(grouping: stuffs) { model in
            let calendar = Calendar.current
            let components: DateComponents
            switch period {
            case .monthly:
                components = calendar.dateComponents([.year, .month], from: model.occurredAt)
            case .yearly:
                components = calendar.dateComponents([.year], from: model.occurredAt)
            }
            return calendar.date(from: components) ?? model.occurredAt
        }
    }

    private func title(for date: Date) -> String {
        let formatter = DateFormatter()
        switch period {
        case .monthly:
            formatter.dateFormat = "LLLL yyyy"
        case .yearly:
            formatter.dateFormat = "yyyy"
        }
        return formatter.string(from: date)
    }
}

#Preview(traits: .sampleData) {
    RecapNavigationView()
}
