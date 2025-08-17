import AppIntents
import SwiftData

@MainActor
struct GetPreviousStuffIntent: AppIntent {
    nonisolated static var title: LocalizedStringResource {
        "Get Previous Stuff"
    }

    @Parameter(title: "Before Date")
    private var date: Date

    @Dependency private var modelContainer: ModelContainer

    func perform() throws -> some ReturnsValue<StuffEntity?> {
        let model = try StuffService.previousStuff(
            context: modelContainer.mainContext,
            before: date
        )
        let entity = model.flatMap(StuffEntity.init)
        return .result(value: entity)
    }
}
