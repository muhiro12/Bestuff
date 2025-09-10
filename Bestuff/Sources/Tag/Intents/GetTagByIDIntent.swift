import AppIntents
import SwiftData

struct GetTagByIDIntent: AppIntent {
    @Parameter(title: "Tag ID")
    private var id: String

    @Dependency private var modelContainer: ModelContainer

    static var title: LocalizedStringResource {
        "Get Tag By ID"
    }

    @MainActor
    func perform() throws -> some ReturnsValue<TagEntity?> {
        let trimmed = id.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw $id.needsValueError()
        }
        let entity = try TagService.get(
            context: modelContainer.mainContext,
            id: trimmed
        )
        return .result(value: entity)
    }
}
