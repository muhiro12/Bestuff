//
//  RecapListView.swift
//  Bestuff
//
//  Created by Hiromu Nakano on 2025/07/11.
//

import SwiftData
import SwiftUI

struct RecapListView: View {
    @Query(sort: \Stuff.occurredAt, order: .reverse)
    private var stuffs: [Stuff]

    @Binding private var selection: Date?
    @Binding private var period: RecapPeriod

    init(selection: Binding<Date?>, period: Binding<RecapPeriod>) {
        _selection = selection
        _period = period
    }

    var body: some View {
        List(selection: $selection) {
            Picker("Period", selection: $period) {
                ForEach(RecapPeriod.allCases) { period in
                    Text(period.title).tag(period)
                }
            }
            .pickerStyle(.segmented)
            .padding(.vertical)

            ForEach(sortedKeys, id: \.self) { date in
                Text(title(for: date))
                    .tag(date)
            }
        }
        .navigationTitle(Text("Recap"))
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

    private var sortedKeys: [Date] {
        groupedStuffs.keys.sorted(by: >)
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
    RecapListView(
        selection: .constant(nil),
        period: .constant(.monthly)
    )
}
