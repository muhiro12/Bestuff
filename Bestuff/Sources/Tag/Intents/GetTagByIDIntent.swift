import AppIntents
import SwiftData

@MainActor
struct GetTagByIDIntent: AppIntent {
    @Parameter(title: "Tag ID")
    private var id: String

    @Dependency private var modelContainer: ModelContainer

    nonisolated static var title: LocalizedStringResource {
        "Get Tag By ID"
    }

    func perform() throws -> some ReturnsValue<TagEntity?> {
        let entity = try TagService.get(
            context: modelContainer.mainContext,
            id: id
        )
        return .result(value: entity)
    }
}
