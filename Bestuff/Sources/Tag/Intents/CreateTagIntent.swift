import AppIntents
import SwiftData

@MainActor
struct CreateTagIntent: AppIntent {
    @Parameter(title: "Name")
    private var name: String
    @Dependency private var modelContainer: ModelContainer

    nonisolated static var title: LocalizedStringResource {
        "Create Tag"
    }

    func perform() throws -> some ReturnsValue<TagEntity> {
        let tag = TagService.create(context: modelContainer.mainContext, name: name)
        guard let entity = TagEntity(tag) else {
            throw TagError.tagNotFound
        }
        return .result(value: entity)
    }
}
