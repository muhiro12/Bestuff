import SwiftData
import SwiftUI

struct TagNavigationView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selection: Tag?
    @AppStorage(StringAppStorageKey.tagSearchText)
    private var searchText
    @State private var duplicateCount: Int = 0
    @AppStorage(StringAppStorageKey.tagFilterType)
    private var storedFilterType

    private var filterType: TagType? {
        get {
            if storedFilterType == "all" {
                return nil
            }
            return TagType(rawValue: storedFilterType)
        }
        set {
            storedFilterType = newValue?.rawValue ?? "all"
        }
    }

    var body: some View {
        NavigationSplitView {
            VStack(spacing: 8) {
                Picker("Filter", selection: Binding(get: {
                    filterType ?? .label
                }, set: { newValue in
                    storedFilterType = newValue?.rawValue ?? "all"
                    if searchText.isEmpty {
                        // no-op
                    }
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
                    filterType: Binding(get: { filterType }, set: { storedFilterType = $0?.rawValue ?? "all" })
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
        .onReceive(NotificationCenter.default.publisher(for: .tagDuplicatesDidChange)) { _ in
            refreshDuplicateCount()
        }
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
