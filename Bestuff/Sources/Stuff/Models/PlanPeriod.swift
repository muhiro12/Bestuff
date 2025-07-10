//
//  PlanPeriod.swift
//  Bestuff
//
//  Created by Codex on 2025/07/12.
//

import AppIntents

enum PlanPeriod: String, CaseIterable, Identifiable, AppEnum {
    case today
    case thisWeek
    case nextTrip
    case nextMonth
    case nextYear

    var id: Self { self }

    nonisolated static var typeDisplayRepresentation: TypeDisplayRepresentation {
        .init(name: "Plan Period")
    }

    nonisolated static var caseDisplayRepresentations: [Self: DisplayRepresentation] {
        [
            .today: .init(stringLiteral: "Today"),
            .thisWeek: .init(stringLiteral: "This Week"),
            .nextTrip: .init(stringLiteral: "Next Trip"),
            .nextMonth: .init(stringLiteral: "Next Month"),
            .nextYear: .init(stringLiteral: "Next Year")
        ]
    }

    var title: String {
        switch self {
        case .today:
            "Today"
        case .thisWeek:
            "This Week"
        case .nextTrip:
            "Next Trip"
        case .nextMonth:
            "Next Month"
        case .nextYear:
            "Next Year"
        }
    }

    var promptDescription: String {
        switch self {
        case .today:
            "today"
        case .thisWeek:
            "this week"
        case .nextTrip:
            "the next trip"
        case .nextMonth:
            "next month"
        case .nextYear:
            "next year"
        }
    }
}
