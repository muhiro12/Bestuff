import Foundation
import SwiftData
#if canImport(FoundationModels)
import FoundationModels
#endif

@MainActor
enum StuffService {
    static func create(
        context: ModelContext,
        title: String,
        note: String?,
        occurredAt: Date,
        tags: [Tag]
    ) -> Stuff {
        Logger(#file).info("Creating stuff titled '\(title)'")
        let model = Stuff.create(
            title: title,
            note: note,
            occurredAt: occurredAt,
            tags: tags
        )
        context.insert(model)
        Logger(#file).notice("Created stuff with id \(String(describing: model.id))")
        return model
    }

    static func delete(model: Stuff) {
        Logger(#file).info("Deleting stuff with id \(String(describing: model.id))")
        model.delete()
        Logger(#file).notice("Deleted stuff with id \(String(describing: model.id))")
    }

    static func predict(context: ModelContext, speech: String) async throws -> Stuff {
        Logger(#file).info("Predicting stuff from speech")
        #if canImport(FoundationModels)
        let prediction = try await generatePrediction(from: speech)
        let model = Stuff.create(
            title: prediction.title,
            note: prediction.note,
            score: prediction.score,
            occurredAt: .now
        )
        #else
        // Fallback: create a basic item using the speech as title
        let model = Stuff.create(
            title: speech,
            note: nil,
            score: 50,
            occurredAt: .now
        )
        #endif
        context.insert(model)
        Logger(#file).notice("Predicted stuff with id \(String(describing: model.id))")
        return model
    }

    static func update(
        model: Stuff,
        title: String,
        note: String?,
        occurredAt: Date,
        tags: [Tag]
    ) -> Stuff {
        Logger(#file).info("Updating stuff with id \(String(describing: model.id))")
        model.update(
            title: title,
            note: note,
            occurredAt: occurredAt,
            tags: tags
        )
        Logger(#file).notice("Updated stuff with id \(String(describing: model.id))")
        return model
    }

    #if canImport(FoundationModels)
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
    #endif
}
