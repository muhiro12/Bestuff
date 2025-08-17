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
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                NavigationLink(value: "duplicates") {
                    Label("Duplicates", systemImage: "square.stack.3d.up")
                }
            }
        }
        .navigationDestination(for: String.self) { value in
            if value == "duplicates" {
                DuplicateTagListView()
            }
        }
    }
}

#Preview(traits: .sampleData) {
    TagNavigationView()
}
