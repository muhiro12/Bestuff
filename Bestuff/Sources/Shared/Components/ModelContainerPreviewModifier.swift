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
        for stuff in SampleData.stuffs {
            let tagModels: [Tag] = stuff.tags.map {
                Tag.findOrCreate(name: $0, in: context)
            }
            _ = StuffService.create(
                context: context,
                title: stuff.title,
                note: stuff.note,
                occurredAt: .now,
                tags: tagModels
            )
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
