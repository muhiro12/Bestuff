import SwiftUI

struct TagNavigationView: View {
    @State private var selection: Tag?

    var body: some View {
        NavigationSplitView {
            TagListView(selection: $selection)
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
    }
}

#Preview(traits: .sampleData) {
    TagNavigationView()
}
