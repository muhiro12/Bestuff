import Foundation
import SwiftData

public enum StuffService {
    public static func create(
        context: ModelContext,
        title: String,
        note: String?,
        occurredAt: Date,
        tags: [Tag]
    ) -> Stuff {
        Logger(#file).info("Creating stuff titled '\(title)'")
        let model = Stuff.create(
            title: title,
            note: note,
            occurredAt: occurredAt,
            tags: tags
        )
        context.insert(model)
        Logger(#file).notice("Created stuff with id \(String(describing: model.id))")
        return model
    }

    public static func delete(model: Stuff) {
        Logger(#file).info("Deleting stuff with id \(String(describing: model.id))")
        model.delete()
        Logger(#file).notice("Deleted stuff with id \(String(describing: model.id))")
    }

    public static func update(
        model: Stuff,
        title: String,
        note: String?,
        occurredAt: Date,
        tags: [Tag]
    ) -> Stuff {
        Logger(#file).info("Updating stuff with id \(String(describing: model.id))")
        model.update(
            title: title,
            note: note,
            occurredAt: occurredAt,
            tags: tags
        )
        Logger(#file).notice("Updated stuff with id \(String(describing: model.id))")
        return model
    }

    // Note: prediction APIs are provided in app target as an extension because they depend on FoundationModels/AppIntents.
}
