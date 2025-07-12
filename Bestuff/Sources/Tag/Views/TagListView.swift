import SwiftData
import SwiftUI

struct TagListView: View {
    @Environment(\.modelContext)
    private var modelContext

    @Query(sort: \Tag.name)
    private var queriedTags: [Tag]

    @Binding private var selection: Tag?

    init(selection: Binding<Tag?>) {
        _selection = selection
    }

    var body: some View {
        List(selection: $selection) {
            ForEach(queriedTags) { tag in
                Text(tag.name).tag(tag)
            }
        }
        .navigationTitle("Tags")
    }
}

#Preview(traits: .sampleData) {
    NavigationStack {
        TagListView(selection: .constant(nil))
    }
}
