//
//  PlanPeriod.swift
//  Bestuff
//
//  Created by Codex on 2025/07/12.
//

import AppIntents

enum PlanPeriod: String, CaseIterable, Identifiable, AppEnum {
    case nextMonth
    case nextYear

    var id: Self { self }

    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        .init(name: "Plan Period")
    }

    static var caseDisplayRepresentations: [Self: DisplayRepresentation] {
        [
            .nextMonth: .init("Next Month"),
            .nextYear: .init("Next Year")
        ]
    }

    var title: String {
        switch self {
        case .nextMonth:
            "Next Month"
        case .nextYear:
            "Next Year"
        }
    }

    var promptDescription: String {
        switch self {
        case .nextMonth:
            "next month"
        case .nextYear:
            "next year"
        }
    }
}
