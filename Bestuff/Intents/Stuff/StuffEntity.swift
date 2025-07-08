import AppIntents
import SwiftData

@Observable
final class StuffEntity: AppEntity {
    static let typeDisplayRepresentation: TypeDisplayRepresentation = .init(name: "Stuff")
    static var defaultQuery = StuffEntityQuery()

    var displayRepresentation: DisplayRepresentation {
        .init(title: title, subtitle: category)
    }

    let id: String
    let title: String
    let category: String
    let note: String?

    fileprivate init(id: String, title: String, category: String, note: String?) {
        self.id = id
        self.title = title
        self.category = category
        self.note = note
    }
}

extension StuffEntity {
    convenience init?(_ model: Stuff) {
        guard let encodedID = try? model.id.base64Encoded() else {
            return nil
        }
        self.init(id: encodedID, title: model.title, category: model.category, note: model.note)
    }

    func model(in context: ModelContext) throws -> Stuff {
        guard
            let id = try? PersistentIdentifier(base64Encoded: id),
            let model = try context.fetch(FetchDescriptor<Stuff>(predicate: #Predicate { $0.id == id })).first
        else {
            throw StuffError.stuffNotFound
        }
        return model
    }
}
