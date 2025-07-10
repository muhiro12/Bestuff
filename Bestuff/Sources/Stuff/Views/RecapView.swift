import SwiftData
import SwiftUI

enum RecapPeriod: String, CaseIterable, Identifiable {
    case monthly
    case yearly

    var id: Self { self }

    var title: String {
        switch self {
        case .monthly:
            "Monthly"
        case .yearly:
            "Yearly"
        }
    }
}

struct RecapView: View {
    @Query(sort: \Stuff.occurredAt, order: .reverse)
    private var stuffs: [Stuff]
    @State private var period: RecapPeriod = .monthly
    @State private var selection: Date?
    @State private var stuffSelection: Stuff?

    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                Picker("Period", selection: $period) {
                    ForEach(RecapPeriod.allCases) { period in
                        Text(period.title).tag(period)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.vertical)

                ForEach(sortedKeys, id: \.self) { date in
                    NavigationLink(value: date) {
                        Text(title(for: date))
                    }
                }
            }
            .navigationTitle(Text("Recap"))
        } detail: {
            if let stuff = stuffSelection {
                StuffDetailView()
                    .environment(stuff)
            } else if let date = selection {
                RecapDetailView(
                    date: date,
                    period: period,
                    stuffs: groupedStuffs[date] ?? [],
                    selection: $stuffSelection
                )
                .navigationTitle(Text(title(for: date)))
            } else {
                Text("Select Period")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationDestination(for: Date.self) { date in
            RecapDetailView(
                date: date,
                period: period,
                stuffs: groupedStuffs[date] ?? [],
                selection: $stuffSelection
            )
        }
        .navigationDestination(for: Stuff.self) { stuff in
            StuffDetailView()
                .environment(stuff)
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
    RecapView()
}
