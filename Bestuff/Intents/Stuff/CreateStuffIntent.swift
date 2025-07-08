import AppIntents
import SwiftData

struct CreateStuffIntent: AppIntent {
    typealias Input = (context: ModelContext, title: String, category: String, note: String?)
    typealias Output = StuffEntity

    @Parameter(title: "Title")
    private var title: String

    @Parameter(title: "Category")
    private var category: String

    @Parameter(title: "Note")
    private var note: String?

    @Dependency private var modelContainer: ModelContainer

    static let title: LocalizedStringResource = "Create Stuff"

    static func perform(_ input: Input) throws -> Output {
        let (context, title, category, note) = input
        let model = Stuff(title: title, category: category, note: note)
        context.insert(model)
        guard let entity = StuffEntity(model) else {
            throw StuffError.stuffNotFound
        }
        return entity
    }

    func perform() throws -> some ReturnsValue<StuffEntity> {
        let result = try Self.perform((context: modelContainer.mainContext, title: title, category: category, note: note))
        return .result(value: result)
    }
}
