import AppIntents
import SwiftData

@MainActor
struct GetPreviousStuffsIntent: AppIntent {
    nonisolated static var title: LocalizedStringResource { "Get Previous Stuffs" }

    @Parameter(title: "Before Date")
    private var date: Date

    @Dependency private var modelContainer: ModelContainer

    func perform() throws -> some ReturnsValue<[StuffEntity]> {
        let models = try StuffService.previousStuffs(
            context: modelContainer.mainContext,
            before: date
        )
        return .result(value: models.compactMap(StuffEntity.init))
    }
}
