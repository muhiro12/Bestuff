import AppIntents
import SwiftData

struct StuffEntityQuery: EntityStringQuery {
    @Dependency private var modelContainer: ModelContainer

    func entities(for identifiers: [StuffEntity.ID]) throws -> [StuffEntity] {
        try identifiers.compactMap { encodedID in
            guard
                let id = try? PersistentIdentifier(base64Encoded: encodedID),
                let model = try modelContainer.mainContext.fetch(
                    FetchDescriptor<Stuff>(predicate: #Predicate { $0.id == id })
                ).first
            else {
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
        try modelContainer.mainContext.fetch(
            FetchDescriptor(
                sortBy: [SortDescriptor(\Stuff.createdAt, order: .reverse)],
                fetchLimit: 5
            )
        ).compactMap(StuffEntity.init)
    }
}
