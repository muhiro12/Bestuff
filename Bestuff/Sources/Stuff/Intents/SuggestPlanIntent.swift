import AppIntents
import Foundation
import FoundationModels
import SwiftData
import SwiftUtilities

@Generable
nonisolated struct PlanSuggestions {
    @Guide(description: "Recommended actions", .count(5))
    var tasks: [String]
}

struct SuggestPlanIntent: AppIntent, IntentPerformer {
    typealias Input = (context: ModelContext, period: PlanPeriod)
    typealias Output = PlanSuggestions

    nonisolated static var title: LocalizedStringResource {
        "Suggest Plan"
    }

    @Parameter(title: "Period")
    private var period: PlanPeriod

    @Dependency private var modelContainer: ModelContainer

    static func perform(_ input: Input) async throws -> Output {
        let (context, period) = input
        var descriptor = FetchDescriptor(
            sortBy: [SortDescriptor(\Stuff.score, order: .reverse)]
        )
        descriptor.fetchLimit = 5
        let stuffs = try context.fetch(descriptor)
        let language = Locale.current.language.languageCode?.identifier ?? Locale.current.identifier
        let timeframe = period == .nextMonth ? "next month" : "next year"
        let items = stuffs.map { "\($0.title) - \($0.category) (\($0.score))" }.joined(separator: "\n")
        let prompt = """
            Based on the following high scoring items, suggest what to do in \(timeframe). Respond in \(language).
            Items:\n\(items)
            """
        let session = LanguageModelSession()
        let response = try await session.respond(
            to: prompt,
            generating: PlanSuggestions.self
        )
        return response.content
    }

    func perform() async throws -> some ReturnsValue<PlanSuggestions> {
        let suggestions = try await Self.perform((context: modelContainer.mainContext, period: period))
        return .result(value: suggestions)
    }
}
