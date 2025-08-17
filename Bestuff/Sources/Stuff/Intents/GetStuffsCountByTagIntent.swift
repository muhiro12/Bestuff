import AppIntents
import SwiftData

@MainActor
struct GetStuffsCountByTagIntent: AppIntent {
    nonisolated static var title: LocalizedStringResource { "Get Stuffs Count By Tag" }

    @Parameter(title: "Tag Name")
    private var name: String

    @Parameter(title: "Tag Type")
    private var type: TagTypeIntent

    @Dependency private var modelContainer: ModelContainer

    func perform() throws -> some ReturnsValue<Int> {
        let tag = try Tag.fetch(byName: name, type: type.modelType, in: modelContainer.mainContext)
        return .result(value: tag?.stuffs?.count ?? 0)
    }
}
