import AppIntents
import SwiftData
import SwiftUtilities

struct UpdateStuffIntent: AppIntent, IntentPerformer {
    typealias Input = (
        context: ModelContext,
        model: Stuff,
        title: String,
        category: String,
        note: String?,
        occurredAt: Date
    )
    typealias Output = Stuff

    nonisolated static var title: LocalizedStringResource {
        "Update Stuff"
    }

    @Parameter(title: "Stuff")
    private var stuff: StuffEntity

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
        let (context, model, title, category, note, occurredAt) = input
        model.title = title
        model.category = category
        model.note = note
        model.occurredAt = occurredAt
        return model
    }

    func perform() throws -> some ReturnsValue<StuffEntity> {
        let model = try stuff.model(in: modelContainer.mainContext)
        let updated = try Self.perform(
            (
                context: modelContainer.mainContext,
                model: model,
                title: title,
                category: category,
                note: note,
                occurredAt: occurredAt
            )
        )
        guard let entity = StuffEntity(updated) else {
            throw StuffError.stuffNotFound
        }
        return .result(value: entity)
    }
}
