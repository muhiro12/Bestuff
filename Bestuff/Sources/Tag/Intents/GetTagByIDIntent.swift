import AppIntents
import SwiftData

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
        let persistentID = try PersistentIdentifier(base64Encoded: input.id)
        guard let tag = try input.context.fetch(
            FetchDescriptor<Tag>(predicate: #Predicate { $0.id == persistentID })
        ).first else {
            return nil
        }
        return TagEntity(tag)
    }

    @MainActor
    func perform() throws -> some ReturnsValue<TagEntity?> {
        let entity = try Self.perform((context: modelContainer.mainContext, id: id))
        return .result(value: entity)
    }
}
