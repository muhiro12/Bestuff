import AppIntents
import Foundation
import FoundationModels
import SwiftData

@MainActor
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
        try await StuffService.predict(context: input.context, speech: input.speech)
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

}
