import AppIntents
import SwiftData
import SwiftUtilities

struct DeleteStuffIntent: AppIntent, IntentPerformer {
    typealias Input = Stuff
    typealias Output = Void

    nonisolated static var title: LocalizedStringResource {
        "Delete Stuff"
    }

    @Parameter(title: "Stuff")
    private var stuff: StuffEntity

    @Dependency private var modelContainer: ModelContainer

    static func perform(_ input: Input) throws -> Output {
        let model = input
        model.delete()
    }

    func perform() throws -> some IntentResult {
        let entity = stuff
        let model = try entity.model(in: modelContainer.mainContext)
        try Self.perform(model)
        return .result()
    }
}
