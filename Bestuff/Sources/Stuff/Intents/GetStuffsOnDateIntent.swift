import AppIntents
import SwiftData

@MainActor
struct GetStuffsOnDateIntent: AppIntent {
    nonisolated static var title: LocalizedStringResource {
        "Get Stuffs On Date"
    }

    @Parameter(title: "Date")
    private var date: Date

    @Dependency private var modelContainer: ModelContainer

    func perform() throws -> some ReturnsValue<[StuffEntity]> {
        let models = try StuffService.stuffs(
            context: modelContainer.mainContext,
            sameDayAs: date
        )
        let entities = models.compactMap(StuffEntity.init)
        return .result(value: entities)
    }
}
