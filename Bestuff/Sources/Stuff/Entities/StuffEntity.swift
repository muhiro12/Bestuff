import AppIntents
import FoundationModels
import SwiftData

@Generable
nonisolated struct StuffEntity {
    let id: String
    let title: String
    let note: String?
    let score: Int
    let tags: [String]
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
            subtitle: .init(stringLiteral: note ?? "")
        )
    }
}

extension StuffEntity: ModelBridgeable {
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    init?(_ model: Stuff) {
        guard let encodedID = try? model.id.base64Encoded() else {
            return nil
        }
        let occurredAtString = Self.dateFormatter.string(from: model.occurredAt)
        self.init(
            id: encodedID,
            title: model.title,
            note: model.note,
            score: model.score,
            tags: model.tags?.map(\.name) ?? [],
            occurredAt: occurredAtString
        )
    }

    func model(in context: ModelContext) throws -> Stuff {
        guard let persistentID = try? PersistentIdentifier(base64Encoded: id),
              let occurredDate = Self.dateFormatter.date(from: occurredAt),
              let model = try context.fetch(
                FetchDescriptor<Stuff>(predicate: #Predicate {
                    $0.id == persistentID
                })
              ).first else {
            throw StuffError.stuffNotFound
        }
        model.update(occurredAt: occurredDate)
        if !tags.isEmpty {
            let tagModels: [Tag] = tags.map { Tag.findOrCreate(name: $0, in: context) }
            model.update(tags: tagModels)
        }
        return model
    }
}
