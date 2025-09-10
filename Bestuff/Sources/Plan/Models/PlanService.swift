import Foundation
import FoundationModels
import SwiftData

enum PlanService {
    static func plan(context: ModelContext, period: PlanPeriod) async throws -> PlanSuggestion {
        Logger(#file).info("Generating plan suggestions for \(period.rawValue)")
        var descriptor = FetchDescriptor(
            sortBy: [SortDescriptor(\Stuff.score, order: .reverse)]
        )
        descriptor.fetchLimit = 5
        let models = try context.fetch(descriptor)
        let items = models.map {
            "\($0.title) score \($0.score)"
        }.joined(separator: "\n")
        let all = (try? context.fetch(FetchDescriptor<Stuff>())) ?? []
        let liked = all.filter {
            $0.isCompleted || ($0.lastFeedback ?? 0) > 0 || $0.score >= 80
        }
        let disliked = all.filter {
            ($0.lastFeedback ?? 0) < 0 || $0.score <= 20
        }
        func topTags(from array: [Stuff], limit: Int) -> [String] {
            var counts: [String: Int] = [:]
            for s in array {
                for name in (s.tags ?? []).map(\.name) {
                    counts[name, default: 0] += 1
                }
            }
            return counts.sorted { $0.value > $1.value }.prefix(limit).map(\.key)
        }
        let preferredTags = topTags(from: liked, limit: 5)
        let avoidedTags = topTags(from: disliked, limit: 5)
        let language = Locale.current.language.languageCode?.identifier ?? Locale.current.identifier
        let example = """
            Example PlanItem:
            - title: Prepare weekly meal plan
            - rationale: Planning meals reduces decision fatigue and food waste.
            - steps:
              1. List 5 easy recipes
              2. Check pantry for ingredients
              3. Create shopping list
              4. Schedule cooking slots
            - estimatedMinutes: 45
            - resources: Notes app, Grocery store app
            - risks: Missing ingredients, Over-scheduling
            - successCriteria: 5 meals planned, One grocery trip done
            - priority: 2
            """
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

            Preferences to consider:
            - Prefer themes related to tags: \(preferredTags.joined(separator: ", "))
            - Avoid themes related to tags: \(avoidedTags.joined(separator: ", "))

            Follow this example for formatting and specificity:
            \(example)

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
}
