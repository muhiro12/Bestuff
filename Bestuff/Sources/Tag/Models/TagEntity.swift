import AppIntents
import FoundationModels
import SwiftData

@Generable
nonisolated struct TagEntity {
    let id: String
    let name: String
}

extension TagEntity: AppEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        .init(name: "Tag")
    }
    static var defaultQuery: TagEntityQuery {
        .init()
    }

    var displayRepresentation: DisplayRepresentation {
        .init(title: .init(stringLiteral: name))
    }
}

extension TagEntity: ModelBridgeable {
    init?(_ model: Tag) {
        guard let encodedID = try? model.id.base64Encoded() else {
            return nil
        }
        self.init(id: encodedID, name: model.name)
    }

    func model(in context: ModelContext) throws -> Tag {
        guard let persistentID = try? PersistentIdentifier(base64Encoded: id),
              let model = try context.fetch(
                FetchDescriptor<Tag>(predicate: #Predicate {
                    $0.id == persistentID
                })
              ).first else {
            throw TagError.tagNotFound
        }
        return model
    }
}
