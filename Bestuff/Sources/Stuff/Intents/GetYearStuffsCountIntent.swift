import AppIntents
import SwiftData

@MainActor
struct GetYearStuffsCountIntent: AppIntent {
    nonisolated static var title: LocalizedStringResource {
        "Get Year Stuffs Count"
    }

    @Parameter(title: "Any Date In Year")
    private var date: Date

    @Dependency private var modelContainer: ModelContainer

    func perform() throws -> some ReturnsValue<Int> {
        let count = try StuffService.yearStuffsCount(
            context: modelContainer.mainContext,
            date: date
        )
        return .result(value: count)
    }
}
