import AppIntents
import SwiftData

@MainActor
struct GetTagByIDIntent: AppIntent, IntentPerformer {
    typealias Input = (context: ModelContext, id: String)
    typealias Output = TagEntity?

    @Parameter(title: "Tag ID")
    private var id: String

    @Dependency private var modelContainer: ModelContainer

    nonisolated static var title: LocalizedStringResource {
        "Get Tag By ID"
    }

    static func perform(_ input: Input) throws -> Output {
        try TagService.get(context: input.context, id: input.id)
    }

    func perform() throws -> some ReturnsValue<TagEntity?> {
        let entity = try Self.perform((context: modelContainer.mainContext, id: id))
        return .result(value: entity)
    }
}
