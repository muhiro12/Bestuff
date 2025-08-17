import SwiftData
import SwiftUI

struct TagNavigationView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selection: Tag?
    @State private var searchText = ""
    @State private var duplicateCount: Int = 0

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
                    if duplicateCount > 0 {
                        Label("Duplicates (\(duplicateCount))", systemImage: "square.stack.3d.up")
                    } else {
                        Label("Duplicates", systemImage: "square.stack.3d.up")
                    }
                }
            }
        }
        .navigationDestination(for: String.self) { value in
            if value == "duplicates" {
                DuplicateTagListView()
            }
        }
        .task {
            await refreshDuplicateCount()
        }
    }

    @MainActor
    private func refreshDuplicateCount() {
        let count = (try? TagService.findDuplicates(context: modelContext).count) ?? 0
        duplicateCount = count
    }
}

#Preview(traits: .sampleData) {
    TagNavigationView()
}
