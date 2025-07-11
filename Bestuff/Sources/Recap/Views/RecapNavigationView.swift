//
//  RecapNavigationView.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/07/11.
//

import SwiftData
import SwiftUI
import SwiftUtilities

struct RecapNavigationView: View {
    @Query(sort: \Stuff.occurredAt, order: .reverse)
    private var stuffs: [Stuff]

    @State private var selection: Date?
    @State private var stuffSelection: Stuff?
    @State private var period: RecapPeriod = .monthly

    var body: some View {
        NavigationSplitView {
            RecapListView(
                selection: $selection,
                period: $period
            )
        } content: {
            if let date = selection {
                RecapStuffListView(
                    date: date,
                    period: period,
                    stuffs: groupedStuffs[date] ?? [],
                    selection: $stuffSelection
                )
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
}

#Preview(traits: .sampleData) {
    RecapNavigationView()
}
