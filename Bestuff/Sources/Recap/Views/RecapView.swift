//
//  RecapView.swift
//  Bestuff
//
//  Created by Codex on 2025/07/22.
//

import SwiftUI

struct RecapView: View {
    let date: Date
    let period: RecapPeriod
    let stuffs: [Stuff]
    @Binding var selection: Stuff?

    var body: some View {
        List(stuffs, selection: $selection) { stuff in
            NavigationLink(
                tag: stuff,
                selection: $selection,
                destination: {
                    StuffView()
                        .environment(stuff)
                },
                label: {
                    StuffRow()
                        .environment(stuff)
                }
            )
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
    RecapView(
        date: .now,
        period: .monthly,
        stuffs: [],
        selection: .constant(nil)
    )
}
