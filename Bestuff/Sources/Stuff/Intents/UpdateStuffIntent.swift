import AppIntents
import SwiftData

struct UpdateStuffIntent: AppIntent, IntentPerformer {
    typealias Input = (
        model: Stuff,
        title: String,
        note: String?,
        occurredAt: Date,
        tags: [Tag]
    )
    typealias Output = Stuff

    nonisolated static var title: LocalizedStringResource { "Update Stuff" }

    @Parameter(title: "Stuff")
    private var stuff: StuffEntity

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
        let (model, title, note, occurredAt, tags) = input
        Logger(#file).info("Updating stuff with id \(String(describing: model.id))")
        model.update(
            title: title,
            note: note,
            occurredAt: occurredAt,
            tags: tags
        )
        Logger(#file).notice("Updated stuff with id \(String(describing: model.id))")
        return model
    }

    func perform() throws -> some ReturnsValue<StuffEntity> {
        Logger(#file).info("Running UpdateStuffIntent")
        let model = try stuff.model(in: modelContainer.mainContext)
        let tagModels = try tags.map { try $0.model(in: modelContainer.mainContext) }
        let updatedModel = try Self.perform(
            (
                model: model,
                title: title,
                note: note,
                occurredAt: occurredAt,
                tags: tagModels
            )
        )
        guard let entity = StuffEntity(updatedModel) else {
            Logger(#file).error("Failed to convert Stuff to StuffEntity")
            throw StuffError.stuffNotFound
        }
        Logger(#file).notice("UpdateStuffIntent finished successfully")
        return .result(value: entity)
    }
}
