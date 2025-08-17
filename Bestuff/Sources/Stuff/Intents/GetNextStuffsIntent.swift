import AppIntents
import SwiftData

@MainActor
struct GetNextStuffsIntent: AppIntent {
    nonisolated static var title: LocalizedStringResource { "Get Next Stuffs" }

    @Parameter(title: "After Date")
    private var date: Date

    @Dependency private var modelContainer: ModelContainer

    func perform() throws -> some ReturnsValue<[StuffEntity]> {
        let models = try StuffService.nextStuffs(
            context: modelContainer.mainContext,
            after: date
        )
        return .result(value: models.compactMap(StuffEntity.init))
    }
}
