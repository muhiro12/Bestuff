import AppIntents
import SwiftData

@MainActor
struct CreateTagIntent: AppIntent, IntentPerformer {
    typealias Input = (context: ModelContext, name: String)
    typealias Output = Tag

    @Parameter(title: "Name")
    private var name: String
    @Dependency private var modelContainer: ModelContainer

    nonisolated static var title: LocalizedStringResource {
        "Create Tag"
    }

    static func perform(_ input: Input) throws -> Output {
        Tag.findOrCreate(name: input.name, in: input.context)
    }

    func perform() throws -> some ReturnsValue<TagEntity> {
        let tag = try Self.perform((context: modelContainer.mainContext, name: name))
        guard let entity = TagEntity(tag) else {
            throw TagError.tagNotFound
        }
        return .result(value: entity)
    }
}
