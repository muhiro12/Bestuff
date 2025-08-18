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
            if let filterType {
                Section(sectionTitle(for: filterType)) {
                    ForEach(filteredTags) { tag in
                        Text(tag.displayName)
                            .tag(tag)
                    }
                }
            } else {
                ForEach(groupedTags, id: \.title) { group in
                    Section(group.title) {
                        ForEach(group.tags) { tag in
                            Text(tag.displayName)
                                .tag(tag)
                        }
                    }
                }
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

    private var groupedTags: [(title: String, tags: [Tag])] {
        let base = filteredTags
        let byLabel = base.filter { ($0.type ?? .label) == .label }
        let byPeriod = base.filter { ($0.type ?? .label) == .period }
        let byResource = base.filter { ($0.type ?? .label) == .resource }
        var result: [(title: String, tags: [Tag])] = []
        if byLabel.isEmpty == false {
            result.append((title: sectionTitle(for: .label), tags: byLabel))
        }
        if byPeriod.isEmpty == false {
            result.append((title: sectionTitle(for: .period), tags: byPeriod))
        }
        if byResource.isEmpty == false {
            result.append((title: sectionTitle(for: .resource), tags: byResource))
        }
        return result
    }

    private func sectionTitle(for type: TagType) -> String {
        switch type {
        case .label:
            return "Labels"
        case .period:
            return "Periods"
        case .resource:
            return "Resources"
        }
    }
}

#Preview(traits: .sampleData) {
    NavigationStack {
        TagListView(selection: .constant(nil), searchText: .constant(""), filterType: .constant(nil))
    }
}
