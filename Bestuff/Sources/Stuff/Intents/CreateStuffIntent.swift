import AppIntents
import SwiftData

struct CreateStuffIntent: AppIntent, IntentPerformer {
    typealias Input = (context: ModelContext, title: String, category: String, note: String?, occurredAt: Date)
    typealias Output = Stuff

    nonisolated static var title: LocalizedStringResource {
        "Create Stuff"
    }

    @Parameter(title: "Title")
    private var title: String

    @Parameter(title: "Category")
    private var category: String

    @Parameter(title: "Note")
    private var note: String?

    @Parameter(title: "Date")
    private var occurredAt: Date

    @Dependency private var modelContainer: ModelContainer

    static func perform(_ input: Input) throws -> Output {
        let (context, title, category, note, occurredAt) = input
        Logger(#file).info("Creating stuff titled '\(title)' in category '\(category)'")
        let model = Stuff.create(
            title: title,
            category: category,
            note: note,
            occurredAt: occurredAt
        )
        context.insert(model)
        Logger(#file).notice("Created stuff with id \(String(describing: model.id))")
        return model
    }

    func perform() throws -> some ReturnsValue<StuffEntity> {
        Logger(#file).info("Running CreateStuffIntent")
        let model = try Self.perform((context: modelContainer.mainContext, title: title, category: category, note: note, occurredAt: occurredAt))
        guard let entity = StuffEntity(model) else {
            Logger(#file).error("Failed to convert Stuff to StuffEntity")
            throw StuffError.stuffNotFound
        }
        Logger(#file).notice("CreateStuffIntent finished successfully")
        return .result(value: entity)
    }
}
