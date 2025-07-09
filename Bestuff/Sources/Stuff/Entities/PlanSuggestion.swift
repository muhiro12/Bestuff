//
//  PlanSuggestion.swift
//  Bestuff
//
//  Created by Codex on 2025/07/12.
//

import FoundationModels

@Generable
struct PlanSuggestion {
    @Guide(description: "A list of recommended actions", .count(3))
    var actions: [String]
}
