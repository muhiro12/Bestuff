//
//  PlanStuffIntent.swift
//  Bestuff
//
//  Created by Codex on 2025/07/12.
//

import AppIntents
import FoundationModels
import SwiftData

@MainActor
struct PlanStuffIntent: AppIntent, IntentPerformer {
    typealias Input = (context: ModelContext, period: PlanPeriod)
    typealias Output = PlanSuggestion

    nonisolated static var title: LocalizedStringResource {
        "Plan Stuff"
    }

    @Parameter(title: "Period")
    private var period: PlanPeriod

    @Dependency private var modelContainer: ModelContainer

    static func perform(_ input: Input) async throws -> Output {
        try await PlanService.plan(context: input.context, period: input.period)
    }

    func perform() async throws -> some ReturnsValue<[String]> {
        Logger(#file).info("Running PlanStuffIntent")
        let result = try await Self.perform(
            (context: modelContainer.mainContext, period: period)
        )
        Logger(#file).notice("PlanStuffIntent finished successfully")
        // Maintain simple result for generic integrations by surfacing titles.
        let titles = result.items.map(\.title)
        return .result(value: titles)
    }
}
