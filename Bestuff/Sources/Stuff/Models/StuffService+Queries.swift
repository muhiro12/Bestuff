import Foundation
import SwiftData

extension StuffService {
    // MARK: - Counts

    static func allStuffsCount(context: ModelContext) throws -> Int {
        try context.fetchCount(FetchDescriptor<Stuff>())
    }

    static func yearStuffsCount(context: ModelContext, date: Date) throws -> Int {
        let (start, end) = dateRange(for: date, component: .year)
        let descriptor = FetchDescriptor<Stuff>(
            predicate: #Predicate { model in
                model.occurredAt >= start && model.occurredAt < end
            }
        )
        return try context.fetchCount(descriptor)
    }

    // MARK: - Collections

    static func stuffs(context: ModelContext, monthOf date: Date) throws -> [Stuff] {
        let (start, end) = dateRange(for: date, component: .month)
        let descriptor = FetchDescriptor<Stuff>(
            predicate: #Predicate { model in
                model.occurredAt >= start && model.occurredAt < end
            },
            sortBy: [SortDescriptor(\Stuff.occurredAt, order: .forward)]
        )
        return try context.fetch(descriptor)
    }

    static func stuffs(context: ModelContext, sameDayAs date: Date) throws -> [Stuff] {
        let (start, end) = dateRange(for: date, component: .day)
        let descriptor = FetchDescriptor<Stuff>(
            predicate: #Predicate { model in
                model.occurredAt >= start && model.occurredAt < end
            },
            sortBy: [SortDescriptor(\Stuff.occurredAt, order: .forward)]
        )
        return try context.fetch(descriptor)
    }

    // MARK: - Navigation

    static func nextStuff(context: ModelContext, after date: Date) throws -> Stuff? {
        let descriptor = FetchDescriptor<Stuff>(
            predicate: #Predicate { model in
                model.occurredAt > date
            },
            sortBy: [SortDescriptor(\Stuff.occurredAt, order: .forward)]
        )
        return try context.fetch(descriptor).first
    }

    static func previousStuff(context: ModelContext, before date: Date) throws -> Stuff? {
        let descriptor = FetchDescriptor<Stuff>(
            predicate: #Predicate { model in
                model.occurredAt < date
            },
            sortBy: [SortDescriptor(\Stuff.occurredAt, order: .reverse)]
        )
        return try context.fetch(descriptor).first
    }

    static func nextStuffs(context: ModelContext, after date: Date) throws -> [Stuff] {
        guard let next = try nextStuff(context: context, after: date) else {
            return []
        }
        return try stuffs(context: context, sameDayAs: next.occurredAt)
    }

    static func previousStuffs(context: ModelContext, before date: Date) throws -> [Stuff] {
        guard let prev = try previousStuff(context: context, before: date) else {
            return []
        }
        return try stuffs(context: context, sameDayAs: prev.occurredAt)
    }

    static func nextStuffDate(context: ModelContext, after date: Date) throws -> Date? {
        try nextStuff(context: context, after: date)?.occurredAt
    }

    static func previousStuffDate(context: ModelContext, before date: Date) throws -> Date? {
        try previousStuff(context: context, before: date)?.occurredAt
    }
}

private extension StuffService {
    static func dateRange(for date: Date, component: Calendar.Component) -> (start: Date, end: Date) {
        let calendar = Calendar.current
        switch component {
        case .day:
            let start = calendar.startOfDay(for: date)
            let end = calendar.date(byAdding: .day, value: 1, to: start) ?? start
            return (start, end)
        case .month:
            let comps = calendar.dateComponents([.year, .month], from: date)
            let start = calendar.date(from: comps) ?? calendar.startOfDay(for: date)
            let end = calendar.date(byAdding: .month, value: 1, to: start) ?? start
            return (start, end)
        case .year:
            let comps = calendar.dateComponents([.year], from: date)
            let start = calendar.date(from: comps) ?? calendar.startOfDay(for: date)
            let end = calendar.date(byAdding: .year, value: 1, to: start) ?? start
            return (start, end)
        default:
            let start = calendar.startOfDay(for: date)
            let end = calendar.date(byAdding: .day, value: 1, to: start) ?? start
            return (start, end)
        }
    }
}
