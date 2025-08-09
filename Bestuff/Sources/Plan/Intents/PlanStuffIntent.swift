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
        let (context, period) = input
        Logger(#file).info("Generating plan suggestions for \(period.rawValue)")
        var descriptor = FetchDescriptor(
            sortBy: [SortDescriptor(\Stuff.score, order: .reverse)]
        )
        descriptor.fetchLimit = 5
        let models = try context.fetch(descriptor)
        let items = models.map {
            "\($0.title) score \($0.score)"
        }.joined(separator: "\n")
        let language = Locale.current.language.languageCode?.identifier ?? Locale.current.identifier
        let prompt = """
            You are a helpful planning assistant. The user has these highly rated items:
            \(items)

            Propose actionable plans for \(period.promptDescription).
            Provide rich, specific content so the user clearly understands the proposal.
            For each plan item, include:
            - title: short, action-oriented
            - rationale: why this is recommended, grounded in the items
            - steps: 3–6 concrete steps, each phrased as an action
            - estimatedMinutes: integer total time in minutes (approximate)
            - resources: concrete tools, links, or materials if applicable
            - risks: likely blockers or pitfalls and what to watch out for
            - successCriteria: 2–3 measurable outcomes to know it’s done well
            - priority: 1 (high), 2 (medium), or 3 (low)

            Respond in \(language).
            """
        let session = LanguageModelSession()
        let response = try await session.respond(
            to: prompt,
            generating: PlanSuggestion.self
        )
        Logger(#file).notice("Generated plan suggestions")
        return response.content
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
