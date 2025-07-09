import AppIntents
import FoundationModels
import SwiftData
import SwiftUtilities

@Generable
nonisolated struct StuffEntity {
    let id: String
    let title: String
    let category: String
    let note: String?
    let score: Int
}

extension StuffEntity: AppEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        .init(name: "Stuff")
    }
    static var defaultQuery: StuffEntityQuery {
        .init()
    }

    var displayRepresentation: DisplayRepresentation {
        .init(
            title: .init(stringLiteral: title),
            subtitle: .init(stringLiteral: category)
        )
    }
}

extension StuffEntity: ModelBridgeable {
    init?(_ model: Stuff) {
        guard let encodedID = try? model.id.base64Encoded() else {
            return nil
        }
        self.init(
            id: encodedID,
            title: model.title,
            category: model.category,
            note: model.note,
            score: model.score
        )
    }

    func model(in context: ModelContext) throws -> Stuff {
        guard let persistentID = try? PersistentIdentifier(base64Encoded: id),
              let model = try context.fetch(
                FetchDescriptor<Stuff>(predicate: #Predicate { $0.id == persistentID })
              ).first else {
            throw StuffError.stuffNotFound
        }
        return model
    }
}
