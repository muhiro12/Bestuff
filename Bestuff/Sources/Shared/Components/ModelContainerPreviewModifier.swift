import SwiftData
import SwiftUI

struct ModelContainerPreviewModifier: PreviewModifier {
    static func makeSharedContext() throws -> ModelContainer {
        let schema: Schema = .init([Stuff.self, Tag.self])
        let configuration: ModelConfiguration = .init(
            schema: schema,
            isStoredInMemoryOnly: true
        )
        let container: ModelContainer = try .init(
            for: schema,
            configurations: [configuration]
        )
        let context: ModelContext = .init(container)
        for data in SampleData.stuffs {
            var tagModels: [Tag] = []
            for label in data.labels {
                tagModels.append(Tag.findOrCreate(name: label, in: context, type: .label))
            }
            if let period = data.period {
                tagModels.append(Tag.findOrCreate(name: period, in: context, type: .period))
            }
            for resource in data.resources {
                tagModels.append(Tag.findOrCreate(name: resource, in: context, type: .resource))
            }
            let occurredAt = Calendar.current.date(byAdding: .day, value: data.occurredOffsetDays, to: .now) ?? .now
            let model = StuffService.create(
                context: context,
                title: data.title,
                note: data.note,
                occurredAt: occurredAt,
                tags: tagModels
            )
            model.update(score: data.score, isCompleted: data.isCompleted, lastFeedback: data.lastFeedback, source: data.source)
        }
        return container
    }

    func body(content: Content, context: ModelContainer) -> some View {
        content.modelContainer(context)
    }
}

extension PreviewTrait where T == Preview.ViewTraits {
    static var sampleData: Self {
        .modifier(ModelContainerPreviewModifier())
    }
}
