import SwiftData
import SwiftUI

struct TagListView: View {
    @Environment(\.modelContext)
    private var modelContext

    @Query(sort: \Tag.name)
    private var queriedTags: [Tag]

    @Binding private var selection: Tag?
    @Binding private var searchText: String
    @Binding private var filterType: TagType?

    init(selection: Binding<Tag?>, searchText: Binding<String>, filterType: Binding<TagType?>) {
        _selection = selection
        _searchText = searchText
        _filterType = filterType
    }

    var body: some View {
        List(selection: $selection) {
            ForEach(filteredTags) { tag in
                Text(tag.displayName).tag(tag)
            }
        }
        .navigationTitle("Tags")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                AddTagButton()
            }
            ToolbarItem(placement: .cancellationAction) {
                CloseButton()
            }
        }
    }

    private var filteredTags: [Tag] {
        var base = queriedTags
        if let filterType {
            base = base.filter { $0.type == filterType }
        }
        if searchText.isEmpty { return base }
        return base.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
}

#Preview(traits: .sampleData) {
    NavigationStack {
        TagListView(selection: .constant(nil), searchText: .constant(""), filterType: .constant(nil))
    }
}
