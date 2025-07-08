import AppIntents
import SwiftData
import SwiftUtilities

struct DeleteStuffIntent: AppIntent, IntentPerformer {
    typealias Input = (context: ModelContext, item: StuffEntity)
    typealias Output = Void

    @Parameter(title: "Stuff")
    private var item: StuffEntity

    @Dependency private var modelContainer: ModelContainer

    nonisolated static let title: LocalizedStringResource = "Delete Stuff"

    static func perform(_ input: Input) throws -> Output {
        let (context, entity) = input
        let model = try entity.model(in: context)
        context.delete(model)
    }

    func perform() throws -> some IntentResult {
        try Self.perform((context: modelContainer.mainContext, item: item))
        return .result()
    }
}
