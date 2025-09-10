import AppIntents
import SwiftData

struct GetAllTagsIntent: AppIntent {
    @Dependency private var modelContainer: ModelContainer

    static var title: LocalizedStringResource {
        "Get All Tags"
    }

    @MainActor
    func perform() throws -> some ReturnsValue<[TagEntity]> {
        let tags = try TagService.getAll(context: modelContainer.mainContext)
        return .result(value: tags)
    }
}
