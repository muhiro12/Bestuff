import SwiftData
import SwiftUI
import SwiftUtilities

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

struct RecapOverviewView: View {
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
                    NavigationLink(
                        destination: {
                            RecapView(
                                date: date,
                                period: period,
                                stuffs: groupedStuffs[date] ?? [],
                                selection: $stuffSelection
                            )
                        },
                        tag: date,
                        selection: $selection
                    ) {
                        Text(title(for: date))
                    }
                }
            }
            .navigationTitle(Text("Recap"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    CloseButton()
                }
            }
        } content: {
            if let date = selection {
                RecapView(
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
    RecapOverviewView()
}
