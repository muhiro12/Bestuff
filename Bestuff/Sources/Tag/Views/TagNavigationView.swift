import SwiftUI

struct TagNavigationView: View {
    @State private var selection: Tag?
    @State private var searchText = ""

    var body: some View {
        NavigationSplitView {
            TagListView(
                selection: $selection,
                searchText: $searchText
            )
        } detail: {
            if let tag = selection {
                StuffListView(
                    stuffs: tag.stuffs ?? [],
                    selection: .constant(nil),
                    searchText: .constant("")
                )
                .navigationTitle(tag.name)
            } else {
                Text("Select Tag")
                    .foregroundStyle(.secondary)
            }
        }
        .searchable(text: $searchText)
    }
}

#Preview(traits: .sampleData) {
    TagNavigationView()
}
