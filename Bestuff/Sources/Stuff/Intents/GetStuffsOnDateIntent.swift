import AppIntents
import SwiftData

struct GetStuffsOnDateIntent: AppIntent {
    static var title: LocalizedStringResource {
        "Get Stuffs On Date"
    }

    @Parameter(title: "Date")
    private var date: Date

    @Parameter(title: "Filter Tag Type")
    private var filterType: TagTypeIntent?

    @Dependency private var modelContainer: ModelContainer

    @MainActor
    func perform() throws -> some ReturnsValue<[StuffEntity]> {
        let models = try StuffService.stuffs(
            context: modelContainer.mainContext,
            sameDayAs: date
        )
        let filtered: [Stuff]
        if let filterType {
            filtered = models.filter { model in
                (model.tags ?? []).contains { $0.type == filterType.modelType }
            }
        } else {
            filtered = models
        }
        let entities = filtered.compactMap(StuffEntity.init)
        return .result(value: entities)
    }
}
