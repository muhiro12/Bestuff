//
//  PlanSelection.swift
//  Bestuff
//
//  Created by Codex on 2025/08/09.
//

import Foundation

struct PlanSelection: Hashable {
    let period: PlanPeriod
    let item: PlanItem

    func hash(into hasher: inout Hasher) {
        hasher.combine(period.rawValue)
        hasher.combine(item.title)
        hasher.combine(item.estimatedMinutes)
        hasher.combine(item.priority)
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.period == rhs.period && lhs.item == rhs.item
    }
}
