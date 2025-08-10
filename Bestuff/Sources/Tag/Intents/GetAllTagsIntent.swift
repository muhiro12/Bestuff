import AppIntents
import SwiftData

@MainActor
struct GetAllTagsIntent: AppIntent {
    @Dependency private var modelContainer: ModelContainer

    nonisolated static var title: LocalizedStringResource {
        "Get All Tags"
    }

    func perform() throws -> some ReturnsValue<[TagEntity]> {
        let tags = try TagService.getAll(context: modelContainer.mainContext)
        return .result(value: tags)
    }
}
