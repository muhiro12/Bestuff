import AppIntents
import SwiftData

struct StuffEntityQuery: EntityStringQuery {
    @Dependency private var modelContainer: ModelContainer

    func entities(for identifiers: [StuffEntity.ID]) throws -> [StuffEntity] {
        Logger(#file).info("Fetching entities for \(identifiers.count) identifiers")
        return try identifiers.compactMap { encodedID in
            guard let persistentID = try? PersistentIdentifier(base64Encoded: encodedID),
                  let model = try modelContainer.mainContext.fetch(
                    FetchDescriptor<Stuff>(predicate: #Predicate {
                        $0.id == persistentID
                    })
                  ).first else {
                Logger(#file).error("Failed to decode identifier \(encodedID)")
                return nil
            }
            Logger(#file).notice("Fetched entity for id \(encodedID)")
            return StuffEntity(model)
        }
    }

    func entities(matching string: String) throws -> [StuffEntity] {
        Logger(#file).info("Searching entities matching '\(string)'")
        return try modelContainer.mainContext.fetch(
            FetchDescriptor<Stuff>(predicate: #Predicate {
                $0.title.localizedStandardContains(string) ||
                    ($0.note ?? "").localizedStandardContains(string)
            })
        ).compactMap(StuffEntity.init)
    }

    func suggestedEntities() throws -> [StuffEntity] {
        Logger(#file).info("Fetching suggested entities")
        var descriptor = FetchDescriptor(
            sortBy: [SortDescriptor(\Stuff.occurredAt, order: .reverse)]
        )
        descriptor.fetchLimit = 5
        let result = try modelContainer.mainContext.fetch(
            descriptor
        ).compactMap(StuffEntity.init)
        Logger(#file).notice("Fetched \(result.count) suggested entities")
        return result
    }
}
