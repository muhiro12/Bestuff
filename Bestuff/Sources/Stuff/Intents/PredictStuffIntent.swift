import AppIntents
import Foundation
import FoundationModels
import SwiftData

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
        Logger(#file).info("Predicting stuff from speech")
        let prediction = try await generatePrediction(from: speech)
        let model = Stuff.create(
            title: prediction.title,
            category: prediction.category,
            note: prediction.note,
            score: prediction.score,
            occurredAt: .now
        )
        context.insert(model)
        Logger(#file).notice("Predicted stuff with id \(String(describing: model.id))")
        return model
    }

    func perform() async throws -> some ReturnsValue<StuffEntity> {
        Logger(#file).info("Running PredictStuffIntent")
        let model = try await Self.perform((context: modelContainer.mainContext, speech: speech))
        guard let entity = StuffEntity(model) else {
            Logger(#file).error("Failed to convert Stuff to StuffEntity")
            throw StuffError.stuffNotFound
        }
        Logger(#file).notice("PredictStuffIntent finished successfully")
        return .result(value: entity)
    }

    private static func generatePrediction(from text: String) async throws -> StuffEntity {
        let language = Locale.current.language.languageCode?.identifier ?? Locale.current.identifier
        let prompt = """
            Based on the following user speech, guess a title, category, optional note and a score from 0 to 100 for stuff the user might want to create. Respond in \(language).
            Speech: \(text)
            """
        let session = LanguageModelSession()
        Logger(#file).info("Sending prediction prompt to language model")
        let response = try await session.respond(
            to: prompt,
            generating: StuffEntity.self
        )
        Logger(#file).notice("Received prediction response")
        return response.content
    }
}
