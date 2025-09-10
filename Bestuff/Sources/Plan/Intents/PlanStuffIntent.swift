//
//  PlanStuffIntent.swift
//  Bestuff
//
//  Created by Codex on 2025/07/12.
//

import AppIntents
import FoundationModels
import SwiftData

struct PlanStuffIntent: AppIntent {
    static var title: LocalizedStringResource {
        "Plan Stuff"
    }

    @Parameter(title: "Period")
    private var period: PlanPeriod

    @Dependency private var modelContainer: ModelContainer

    @MainActor
    func perform() async throws -> some ReturnsValue<[String]> {
        Logger(#file).info("Running PlanStuffIntent")
        let result = try await PlanService.plan(
            context: modelContainer.mainContext,
            period: period
        )
        Logger(#file).notice("PlanStuffIntent finished successfully")
        // Maintain simple result for generic integrations by surfacing titles.
        let titles = result.items.map(\.title)
        return .result(value: titles)
    }
}
