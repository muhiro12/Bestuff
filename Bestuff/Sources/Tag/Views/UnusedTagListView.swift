import SwiftData
import SwiftUI

struct UnusedTagListView: View {
    @Environment(\.dismiss)
    private var dismiss
    @Environment(\.modelContext)
    private var modelContext

    @State private var tags: [Tag] = []
    @State private var isProcessing = false

    var body: some View {
        NavigationStack {
            List {
                if tags.isEmpty {
                    Text("No unused labels")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(tags) { tag in
                        Text(tag.name)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    delete(tag)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
            }
            .navigationTitle("Unused Labels")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    CloseButton()
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Delete All", systemImage: "trash") {
                        deleteAll()
                    }
                    .disabled(tags.isEmpty || isProcessing)
                }
            }
            .task(refresh)
        }
    }

    private func refresh() {
        tags = (try? TagService.getUnusedLabels(context: modelContext)) ?? []
    }

    private func deleteAll() {
        isProcessing = true
        for tag in tags {
            tag.delete()
        }
        refresh()
        isProcessing = false
        if tags.isEmpty {
            dismiss()
        }
    }

    private func delete(_ tag: Tag) {
        isProcessing = true
        tag.delete()
        refresh()
        isProcessing = false
    }
}

#Preview(traits: .sampleData) {
    UnusedTagListView()
}
