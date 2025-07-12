import SwiftData
import SwiftUI

struct TagPickerListView: View {
    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.modelContext)
    private var modelContext
    @State private var tags: [Tag] = []

    @Binding private var selection: Set<Tag>

    init(selection: Binding<Set<Tag>>) {
        _selection = selection
    }

    var body: some View {
        List(tags, selection: $selection) { tag in
            Text(tag.name)
                .tag(tag)
        }
        .environment(\.editMode, .constant(.active))
        .navigationTitle("Tags")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                CloseButton()
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Done", action: { dismiss() })
                    .buttonStyle(.borderedProminent)
                    .tint(.accentColor)
            }
        }
        .task {
            if let entities = try? GetAllTagsIntent.perform(modelContext) {
                tags = entities.compactMap { try? $0.model(in: modelContext) }
            }
        }
    }
}

#Preview(traits: .sampleData) {
    NavigationStack {
        TagPickerListView(selection: .constant([]))
    }
    .modelContainer(for: Tag.self, inMemory: true)
}
