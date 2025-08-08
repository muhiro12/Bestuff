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
            Here are some highly rated items:
            \(items)
            Based on these, suggest things I should do in \(period.promptDescription). Answer in \(language).
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
        return .result(value: result.actions)
    }
}
