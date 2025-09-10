import Foundation

enum DateFilter: String, CaseIterable, Identifiable {
    case all
    case today
    case thisWeek
    case thisMonth

    var id: Self { self }

    var title: String {
        switch self {
        case .all:
            "Any Date"
        case .today:
            "Today"
        case .thisWeek:
            "This Week"
        case .thisMonth:
            "This Month"
        }
    }

    func contains(_ date: Date, calendar: Calendar = .current) -> Bool {
        switch self {
        case .all:
            return true
        case .today:
            return calendar.isDateInToday(date)
        case .thisWeek:
            // Use a 7-day rolling window from the start of today
            let start = calendar.startOfDay(for: Date())
            let end = calendar.date(byAdding: .day, value: 7, to: start) ?? start
            return (start ... end).contains(date)
        case .thisMonth:
            guard let interval = calendar.dateInterval(of: .month, for: Date()) else {
                return true
            }
            return interval.contains(date)
        }
    }
}
