import SwiftData
import SwiftUI

struct TagListView: View {
    @Environment(\.modelContext)
    private var modelContext

    @Query(sort: \Tag.name)
    private var queriedTags: [Tag]

    @Binding private var selection: Tag?
    @Binding private var searchText: String

    init(selection: Binding<Tag?>, searchText: Binding<String>) {
        _selection = selection
        _searchText = searchText
    }

    var body: some View {
        List(selection: $selection) {
            ForEach(filteredTags) { tag in
                Text(tag.name).tag(tag)
            }
        }
        .navigationTitle("Tags")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                AddTagButton()
            }
        }
    }

    private var filteredTags: [Tag] {
        if searchText.isEmpty {
            return queriedTags
        } else {
            return queriedTags.filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}

#Preview(traits: .sampleData) {
    NavigationStack {
        TagListView(
            selection: .constant(nil),
            searchText: .constant("")
        )
    }
}
