//
//  RecapListView.swift
//  Bestuff
//
//  Created by Codex on 2025/07/22.
//

import SwiftUI

struct RecapListView: View {
    let date: Date
    let period: RecapPeriod
    let stuffs: [Stuff]
    @Binding var selection: Stuff?

    var body: some View {
        List(stuffs, selection: $selection) { stuff in
            StuffRow()
                .environment(stuff)
                .tag(stuff)
        }
        .navigationTitle(Text(title(for: date)))
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
        date: .now,
        period: .monthly,
        stuffs: [],
        selection: .constant(nil)
    )
}
