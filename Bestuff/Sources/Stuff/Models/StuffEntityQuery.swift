import AppIntents
import SwiftData
import SwiftUtilities

struct StuffEntityQuery: EntityStringQuery {
    @Dependency private var modelContainer: ModelContainer

    func entities(for identifiers: [StuffEntity.ID]) throws -> [StuffEntity] {
        try identifiers.compactMap { encodedID in
            guard let persistentID = try? PersistentIdentifier(base64Encoded: encodedID),
                  let model = try modelContainer.mainContext.fetch(
                    FetchDescriptor<Stuff>(predicate: #Predicate { $0.id == persistentID })
                  ).first else {
                return nil
            }
            return StuffEntity(model)
        }
    }

    func entities(matching string: String) throws -> [StuffEntity] {
        try modelContainer.mainContext.fetch(
            FetchDescriptor<Stuff>(predicate: #Predicate {
                $0.title.localizedStandardContains(string) ||
                    $0.category.localizedStandardContains(string)
            })
        ).compactMap(StuffEntity.init)
    }

    func suggestedEntities() throws -> [StuffEntity] {
        var descriptor = FetchDescriptor(
            sortBy: [SortDescriptor(\Stuff.occurredAt, order: .reverse)]
        )
        descriptor.fetchLimit = 5
        return try modelContainer.mainContext.fetch(
            descriptor
        ).compactMap(StuffEntity.init)
    }
}
