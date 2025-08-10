import SwiftData
import SwiftUI

struct TagPickerListView: View {
    @Environment(\.dismiss)
    private var dismiss
    @Query(sort: \Tag.name)
    private var tags: [Tag]

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
                Button("Done") { dismiss() }
                    .buttonStyle(.borderedProminent)
                    .tint(.accentColor)
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
