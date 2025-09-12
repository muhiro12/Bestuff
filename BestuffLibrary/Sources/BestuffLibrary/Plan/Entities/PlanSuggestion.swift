//
//  PlanSuggestion.swift
//  Bestuff
//
//  Created by Codex on 2025/07/12.
//

import FoundationModels

@Generable
public struct PlanSuggestion {
    @Guide(
        description: "Detailed plan items to act on",
        .count(3)
    )
    public var items: [PlanItem]

    public init(items: [PlanItem]) {
        self.items = items
    }
}

@Generable
public struct PlanItem: Hashable, Sendable {
    @Guide(description: "Short, action-oriented title")
    public var title: String

    @Guide(description: "Why this is recommended")
    public var rationale: String

    @Guide(description: "Step-by-step actions", .count(3))
    public var steps: [String]

    @Guide(description: "Estimated time in minutes (integer)")
    public var estimatedMinutes: Int

    @Guide(description: "Required tools or resources", .count(3))
    public var resources: [String]

    @Guide(description: "Potential risks or blockers", .count(3))
    public var risks: [String]

    @Guide(description: "How to measure success", .count(2))
    public var successCriteria: [String]

    @Guide(description: "Priority where 1=high, 3=low")
    public var priority: Int

    public init(
        title: String,
        rationale: String,
        steps: [String],
        estimatedMinutes: Int,
        resources: [String],
        risks: [String],
        successCriteria: [String],
        priority: Int
    ) {
        self.title = title
        self.rationale = rationale
        self.steps = steps
        self.estimatedMinutes = estimatedMinutes
        self.resources = resources
        self.risks = risks
        self.successCriteria = successCriteria
        self.priority = priority
    }
}
