import AppIntents
import SwiftData

@MainActor
struct UpdateTagIntent: AppIntent, IntentPerformer {
    typealias Input = (model: Tag, name: String)
    typealias Output = Tag

    @Parameter(title: "Tag")
    private var tag: TagEntity

    @Parameter(title: "Name")
    private var name: String

    @Dependency private var modelContainer: ModelContainer

    nonisolated static var title: LocalizedStringResource {
        "Update Tag"
    }

    static func perform(_ input: Input) throws -> Output {
        TagService.update(model: input.model, name: input.name)
    }

    func perform() throws -> some ReturnsValue<TagEntity> {
        let model = try tag.model(in: modelContainer.mainContext)
        let updated = try Self.perform((model: model, name: name))
        guard let entity = TagEntity(updated) else {
            throw TagError.tagNotFound
        }
        return .result(value: entity)
    }
}
