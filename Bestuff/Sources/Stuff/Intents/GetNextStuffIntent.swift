import AppIntents
import SwiftData

@MainActor
struct GetNextStuffIntent: AppIntent {
    nonisolated static var title: LocalizedStringResource {
        "Get Next Stuff"
    }

    @Parameter(title: "After Date")
    private var date: Date

    @Dependency private var modelContainer: ModelContainer

    func perform() throws -> some ReturnsValue<StuffEntity?> {
        let model = try StuffService.nextStuff(
            context: modelContainer.mainContext,
            after: date
        )
        let entity = model.flatMap(StuffEntity.init)
        return .result(value: entity)
    }
}
