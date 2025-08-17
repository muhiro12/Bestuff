//
//  PlanSuggestion.swift
//  Bestuff
//
//  Created by Codex on 2025/07/12.
//

#if canImport(FoundationModels)
import FoundationModels

@Generable
struct PlanSuggestion {
    @Guide(
        description: "Detailed plan items to act on",
        .count(3)
    )
    var items: [PlanItem]
}

@Generable
struct PlanItem: Hashable, Sendable {
    @Guide(description: "Short, action-oriented title")
    var title: String

    @Guide(description: "Why this is recommended")
    var rationale: String

    @Guide(description: "Step-by-step actions", .count(3))
    var steps: [String]

    @Guide(description: "Estimated time in minutes (integer)")
    var estimatedMinutes: Int

    @Guide(description: "Required tools or resources", .count(3))
    var resources: [String]

    @Guide(description: "Potential risks or blockers", .count(3))
    var risks: [String]

    @Guide(description: "How to measure success", .count(2))
    var successCriteria: [String]

    @Guide(description: "Priority where 1=high, 3=low")
    var priority: Int
}
#else
struct PlanSuggestion: Hashable, Sendable {
    var items: [PlanItem]
}

struct PlanItem: Hashable, Sendable {
    var title: String
    var rationale: String
    var steps: [String]
    var estimatedMinutes: Int
    var resources: [String]
    var risks: [String]
    var successCriteria: [String]
    var priority: Int
}
#endif
