import AppIntents
import SwiftData

@MainActor
struct GetAllTagsIntent: AppIntent, IntentPerformer {
    typealias Input = ModelContext
    typealias Output = [TagEntity]

    @Dependency private var modelContainer: ModelContainer

    nonisolated static var title: LocalizedStringResource {
        "Get All Tags"
    }

    static func perform(_ input: Input) throws -> Output {
        try input.fetch(FetchDescriptor<Tag>()).compactMap(TagEntity.init)
    }

    func perform() throws -> some ReturnsValue<[TagEntity]> {
        let tags = try Self.perform(modelContainer.mainContext)
        return .result(value: tags)
    }
}
