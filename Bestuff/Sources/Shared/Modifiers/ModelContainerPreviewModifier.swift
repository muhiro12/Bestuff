import SwiftData
import SwiftUI

struct ModelContainerPreviewModifier: PreviewModifier {
    static func makeSharedContext() throws -> ModelContainer {
        let schema: Schema = .init([Stuff.self])
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
            context.insert(
                Stuff(
                    title: stuff.title,
                    category: stuff.category,
                    note: stuff.note,
                    occurredAt: .now
                )
            )
        }
        return container
    }

    func body(content: Content, context: ModelContainer) -> some View {
        content.modelContainer(context)
    }
}

extension PreviewTrait where T == Preview.ViewTraits {
    @MainActor static var sampleData: Self {
        .modifier(ModelContainerPreviewModifier())
    }
}
