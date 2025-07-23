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
            _ = try? CreateStuffIntent.perform(
                (
                    context: context,
                    title: stuff.title,
                    note: stuff.note,
                    occurredAt: .now,
                    tags: []
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
    static var sampleData: Self {
        .modifier(ModelContainerPreviewModifier())
    }
}
