import AppIntents
import SwiftData

struct CreateTagIntent: AppIntent {
    @Parameter(title: "Name")
    private var name: String
    @Dependency private var modelContainer: ModelContainer

    static var title: LocalizedStringResource {
        "Create Tag"
    }

    @MainActor
    func perform() throws -> some ReturnsValue<TagEntity> {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            throw $name.needsValueError()
        }
        let tag = TagService.create(context: modelContainer.mainContext, name: trimmedName)
        guard let entity = TagEntity(tag) else {
            throw TagError.tagNotFound
        }
        return .result(value: entity)
    }
}
