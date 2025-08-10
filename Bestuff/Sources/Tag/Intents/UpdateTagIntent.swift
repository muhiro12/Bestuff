import AppIntents
import SwiftData

@MainActor
struct UpdateTagIntent: AppIntent {
    @Parameter(title: "Tag")
    private var tag: TagEntity

    @Parameter(title: "Name")
    private var name: String

    @Dependency private var modelContainer: ModelContainer

    nonisolated static var title: LocalizedStringResource {
        "Update Tag"
    }

    func perform() throws -> some ReturnsValue<TagEntity> {
        let model = try tag.model(in: modelContainer.mainContext)
        let updated = TagService.update(model: model, name: name)
        guard let entity = TagEntity(updated) else {
            throw TagError.tagNotFound
        }
        return .result(value: entity)
    }
}
