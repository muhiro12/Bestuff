import AppIntents
import SwiftData

struct TagEntityQuery: EntityStringQuery {
    @Dependency private var modelContainer: ModelContainer

    func entities(for identifiers: [TagEntity.ID]) throws -> [TagEntity] {
        try identifiers.compactMap { id in
            try GetTagByIDIntent.perform((context: modelContainer.mainContext, id: id))
        }
    }

    func entities(matching string: String) throws -> [TagEntity] {
        try modelContainer.mainContext.fetch(
            FetchDescriptor<Tag>(predicate: #Predicate {
                $0.name.localizedStandardContains(string)
            })
        ).compactMap(TagEntity.init)
    }

    func suggestedEntities() throws -> [TagEntity] {
        var descriptor = FetchDescriptor(sortBy: [SortDescriptor(\Tag.name)])
        descriptor.fetchLimit = 5
        return try modelContainer.mainContext.fetch(descriptor).compactMap(TagEntity.init)
    }
}
