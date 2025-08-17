import AppIntents
import SwiftData

@MainActor
struct GetStuffsInMonthIntent: AppIntent {
    nonisolated static var title: LocalizedStringResource {
        "Get Stuffs In Month"
    }

    @Parameter(title: "Any Date In Month")
    private var date: Date

    @Dependency private var modelContainer: ModelContainer

    func perform() throws -> some ReturnsValue<[StuffEntity]> {
        let models = try StuffService.stuffs(
            context: modelContainer.mainContext,
            monthOf: date
        )
        let entities = models.compactMap(StuffEntity.init)
        return .result(value: entities)
    }
}
