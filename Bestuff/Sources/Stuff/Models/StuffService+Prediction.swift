import BestuffLibrary
import Foundation
import FoundationModels
import SwiftData

extension StuffService {
    static func predict(context: ModelContext, speech: String) async throws -> Stuff {
        Logger(#file).info("Predicting stuff from speech")
        let prediction = try await generatePrediction(from: speech)
        let model = Stuff.create(
            title: prediction.title,
            note: prediction.note,
            score: prediction.score,
            occurredAt: .now
        )
        context.insert(model)
        Logger(#file).notice("Predicted stuff with id \(String(describing: model.id))")
        return model
    }

    private static func generatePrediction(from text: String) async throws -> StuffEntity {
        let language = Locale.current.language.languageCode?.identifier ?? Locale.current.identifier
        let prompt = """
            Based on the following user speech, guess a title, optional note and a score from 0 to 100 for stuff the user might want to create. Respond in \(language).
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
