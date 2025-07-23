import AppIntents
import SwiftData

struct CreateStuffIntent: AppIntent, IntentPerformer {
    typealias Input = (
        context: ModelContext,
        title: String,
        note: String?,
        occurredAt: Date,
        tags: [Tag]
    )
    typealias Output = Stuff

    nonisolated static var title: LocalizedStringResource {
        "Create Stuff"
    }

    @Parameter(title: "Title")
    private var title: String

    @Parameter(title: "Note")
    private var note: String?

    @Parameter(title: "Date")
    private var occurredAt: Date

    @Parameter(title: "Tags")
    private var tags: [TagEntity]

    @Dependency private var modelContainer: ModelContainer

    static func perform(_ input: Input) throws -> Output {
        let (context, title, note, occurredAt, tags) = input
        Logger(#file).info("Creating stuff titled '\(title)'")
        let model = Stuff.create(
            title: title,
            note: note,
            occurredAt: occurredAt,
            tags: tags
        )
        context.insert(model)
        Logger(#file).notice("Created stuff with id \(String(describing: model.id))")
        return model
    }

    func perform() throws -> some ReturnsValue<StuffEntity> {
        Logger(#file).info("Running CreateStuffIntent")
        let tagModels = try tags.map { try $0.model(in: modelContainer.mainContext) }
        let model = try Self.perform(
            (
                context: modelContainer.mainContext,
                title: title,
                note: note,
                occurredAt: occurredAt,
                tags: tagModels
            )
        )
        guard let entity = StuffEntity(model) else {
            Logger(#file).error("Failed to convert Stuff to StuffEntity")
            throw StuffError.stuffNotFound
        }
        Logger(#file).notice("CreateStuffIntent finished successfully")
        return .result(value: entity)
    }
}
