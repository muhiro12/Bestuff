import AppIntents
import SwiftData

struct UpdateStuffIntent: AppIntent {
    static var title: LocalizedStringResource { "Update Stuff" }

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

    @MainActor
    func perform() throws -> some ReturnsValue<StuffEntity> {
        Logger(#file).info("Running UpdateStuffIntent")
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            throw $title.needsValueError()
        }
        let model = try stuff.model(in: modelContainer.mainContext)
        let tagModels = try tags.map { try $0.model(in: modelContainer.mainContext) }
        let updatedModel = StuffService.update(
            model: model,
            title: trimmedTitle,
            note: note,
            occurredAt: occurredAt,
            tags: tagModels
        )
        guard let entity = StuffEntity(updatedModel) else {
            Logger(#file).error("Failed to convert Stuff to StuffEntity")
            throw StuffError.stuffNotFound
        }
        Logger(#file).notice("UpdateStuffIntent finished successfully")
        return .result(value: entity)
    }
}
