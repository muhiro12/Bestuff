import AppIntents
import SwiftData

@MainActor
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
        StuffService.delete(model: input)
    }

    func perform() throws -> some IntentResult {
        let entity = stuff
        let model = try entity.model(in: modelContainer.mainContext)
        try Self.perform(model)
        Logger(#file).notice("DeleteStuffIntent finished successfully")
        return .result()
    }
}
