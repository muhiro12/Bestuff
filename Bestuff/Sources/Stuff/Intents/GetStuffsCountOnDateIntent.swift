import AppIntents
import SwiftData

@MainActor
struct GetStuffsCountOnDateIntent: AppIntent {
    nonisolated static var title: LocalizedStringResource { "Get Stuffs Count On Date" }

    @Parameter(title: "Date")
    private var date: Date

    @Dependency private var modelContainer: ModelContainer

    func perform() throws -> some ReturnsValue<Int> {
        let items = try StuffService.stuffs(
            context: modelContainer.mainContext,
            sameDayAs: date
        )
        return .result(value: items.count)
    }
}
