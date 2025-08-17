import AppIntents
import Foundation
import FoundationModels
import SwiftData

@MainActor
struct PredictStuffIntent: AppIntent {
    nonisolated static var title: LocalizedStringResource {
        "Predict Stuff"
    }

    @Parameter(title: "Speech")
    private var speech: String

    @Dependency private var modelContainer: ModelContainer

    func perform() async throws -> some ReturnsValue<StuffEntity> {
        Logger(#file).info("Running PredictStuffIntent")
        let trimmed = speech.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw $speech.needsValueError()
        }
        let model = try await StuffService.predict(
            context: modelContainer.mainContext,
            speech: trimmed
        )
        guard let entity = StuffEntity(model) else {
            Logger(#file).error("Failed to convert Stuff to StuffEntity")
            throw StuffError.stuffNotFound
        }
        Logger(#file).notice("PredictStuffIntent finished successfully")
        return .result(value: entity)
    }
}
