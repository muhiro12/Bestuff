import AppIntents
import FoundationModels
import SwiftData

@Generable
nonisolated struct StuffEntity {
    let id: String
    let title: String
    let category: String
    let note: String?
    let score: Int
    @Guide(description: "yyyyMMdd format")
    let occurredAt: String
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
    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyyMMdd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    init?(_ model: Stuff) {
        guard let encodedID = try? model.id.base64Encoded() else {
            return nil
        }
        let occurredAtString = Self.dateFormatter.string(from: model.occurredAt)
        self.init(
            id: encodedID,
            title: model.title,
            category: model.category,
            note: model.note,
            score: model.score,
            occurredAt: occurredAtString
        )
    }

    func model(in context: ModelContext) throws -> Stuff {
        guard let persistentID = try? PersistentIdentifier(base64Encoded: id),
              let occurredDate = Self.dateFormatter.date(from: occurredAt),
              let model = try context.fetch(
                FetchDescriptor<Stuff>(predicate: #Predicate { $0.id == persistentID })
              ).first else {
            throw StuffError.stuffNotFound
        }
        model.update(occurredAt: occurredDate)
        return model
    }
}
