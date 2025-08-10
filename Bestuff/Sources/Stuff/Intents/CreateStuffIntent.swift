import AppIntents
import SwiftData

@MainActor
struct CreateStuffIntent: AppIntent {

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

    func perform() throws -> some ReturnsValue<StuffEntity> {
        Logger(#file).info("Running CreateStuffIntent")
        let tagModels = try tags.map { try $0.model(in: modelContainer.mainContext) }
        let model = StuffService.create(
            context: modelContainer.mainContext,
            title: title,
            note: note,
            occurredAt: occurredAt,
            tags: tagModels
        )
        guard let entity = StuffEntity(model) else {
            Logger(#file).error("Failed to convert Stuff to StuffEntity")
            throw StuffError.stuffNotFound
        }
        Logger(#file).notice("CreateStuffIntent finished successfully")
        return .result(value: entity)
    }
}
