import AppIntents
import Foundation
import FoundationModels
import SwiftData
import SwiftUtilities

struct PredictStuffIntent: AppIntent, IntentPerformer {
    typealias Input = (context: ModelContext, speech: String)
    typealias Output = Stuff

    nonisolated static var title: LocalizedStringResource {
        "Predict Stuff"
    }

    @Parameter(title: "Speech")
    private var speech: String

    @Dependency private var modelContainer: ModelContainer

    static func perform(_ input: Input) async throws -> Output {
        let (context, speech) = input
        let prediction = try await generatePrediction(from: speech)
        let model = Stuff(
            title: prediction.title,
            category: prediction.category,
            note: prediction.note,
            occurredAt: .now,
            score: prediction.score
        )
        context.insert(model)
        return model
    }

    func perform() async throws -> some ReturnsValue<StuffEntity> {
        let model = try await Self.perform((context: modelContainer.mainContext, speech: speech))
        guard let entity = StuffEntity(model) else {
            throw StuffError.stuffNotFound
        }
        return .result(value: entity)
    }

    private static func generatePrediction(from text: String) async throws -> StuffEntity {
        let language = Locale.current.language.languageCode?.identifier ?? Locale.current.identifier
        let prompt = """
            Based on the following user speech, guess a title, category, optional note and a score from 0 to 100 for stuff the user might want to create. Respond in \(language).
            Speech: \(text)
            """
        let session = LanguageModelSession()
        let response = try await session.respond(
            to: prompt,
            generating: StuffEntity.self
        )
        return response.content
    }
}
