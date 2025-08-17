import SwiftData
import SwiftUI

struct TagNavigationView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selection: Tag?
    @State private var searchText = ""
    @State private var duplicateCount: Int = 0
    @State private var filterType: TagType?

    var body: some View {
        NavigationSplitView {
            VStack(spacing: 8) {
                Picker("Filter", selection: Binding(get: {
                    filterType ?? .label
                }, set: { newValue in
                    filterType = newValue
                    if searchText.isEmpty { /* no-op */ }
                })) {
                    Text("All").tag(TagType?.none)
                    Text("Labels").tag(TagType?.some(.label))
                    Text("Periods").tag(TagType?.some(.period))
                    Text("Resources").tag(TagType?.some(.resource))
                }
                .pickerStyle(.segmented)
                TagListView(
                    selection: $selection,
                    searchText: $searchText,
                    filterType: $filterType
                )
            }
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
            ToolbarItem(placement: .primaryAction) {
                NavigationLink(value: "unused") {
                    Label("Unused", systemImage: "trash")
                }
            }
        }
        .navigationDestination(for: String.self) { value in
            if value == "duplicates" {
                DuplicateTagListView()
            } else if value == "unused" {
                UnusedTagListView()
            }
        }
        .task {
            refreshDuplicateCount()
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
