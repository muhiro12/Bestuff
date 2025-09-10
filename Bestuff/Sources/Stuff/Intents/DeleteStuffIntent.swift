import AppIntents
import SwiftData

struct DeleteStuffIntent: AppIntent {
    static var title: LocalizedStringResource {
        "Delete Stuff"
    }

    @Parameter(title: "Stuff")
    private var stuff: StuffEntity

    @Dependency private var modelContainer: ModelContainer

    @MainActor
    func perform() throws -> some IntentResult {
        let entity = stuff
        let model = try entity.model(in: modelContainer.mainContext)
        StuffService.delete(model: model)
        Logger(#file).notice("DeleteStuffIntent finished successfully")
        return .result()
    }
}
